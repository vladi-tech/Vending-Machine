defmodule VendingMachineApp.VendingMachine do
  use GenServer

  defstruct floor_name: nil,
            machine_id: nil,
            products: %{}

  def start_link(floor_name, machine_id, opts) do
    initial_state = %__MODULE__{floor_name: floor_name, machine_id: machine_id, products: %{}}
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def init(state) do
    products = Repo.all(Product)
    initial_product_load = Enum.map(products, fn product ->
      {product.name, %{product | quantity: 10}}
    end)

    initial_state = %{state | products: Map.new(initial_product_load)}
    {:ok, initial_state}
  end

  # we receive an order request
  def handle_call({:order, order}, _from, state) do
    updated_state = process_order(state, order)
    {:reply, updated_state}
  end

    #we receive a recommendation request
  def handle_call({:recommendation, product_type}, _from, state) do

    #It takes time to recommend some products
    Process.sleep(1000)

    recommended_products = get_recommendation(state, product_type)
    {:reply, recommended_products, state}
  end

  defp in_stock?(state, order) do
    Enum.all?(order, fn {product_name, quantity} ->
      case Map.get(state.products, product_name) do
        nil -> false
        %ProductQuant{quantity: product_quantity} when product_quantity >= quantity -> true
        _ -> false
      end
    end)
  end

  defp get_recommendation(state, product_type) do
    recommended_products =
      state.products
      |> Map.keys()
      |> Enum.filter(fn product_name ->
        product = Map.get(state.products, product_name)
        product.type == product_type
      end)

    recommended_products
  end

  defp process_order(state, order) when in_stock?(state, order) do
    update_products(state, order)
  end

  defp process_order(state, order) do
    restock_products(state, order)
  end

  defp update_products(state, order) do
    {valid_order, invalid_order} = Enum.partition(order, fn {product_name, _} ->
      Map.has_key?(state.products, product_name)
    end)

    if Enum.empty?(invalid_order) do
      updated_state = Enum.reduce(valid_order, state, fn {product_name, order_quantity}, acc ->
        Process.sleep(100)
        IO.puts("Selling #{order_quantity} of #{product_name}")
        updated_product = %{acc.products[product_name] | quantity: acc.products[product_name].quantity - order_quantity}
        updated_stock_values = Map.update!(acc.products, product_name, updated_product)
        %{acc | products: updated_stock_values}
      end)
      {:ok, updated_state}
    else
      {:error, "Some of these products are not sold by the machine center: #{invalid_order}"}
    end
  end

  defp restock_request(state, order) do
    products_to_restock = Enum.filter(order, fn {product_name, _} ->
      product_quantity(state.products, product_name) == 0
    end)

    restocked_products = increase_quantity(products_to_restock, state.products)

    restock_order = build_restock_order(products_to_restock)

    updated_state = %{state | products: restocked_products}

    FloorSupervisor.restock_machine(state.floor_name, state.machine_id, restock_order)

    updated_state
  end

  defp product_quantity(products, product_name) do
    case Map.fetch(products, product_name) do
      {:ok, product} -> product.quantity
      _ -> 0
    end
  end

  defp increase_quantity(products, current_products) do
    Enum.reduce(products, current_products, fn {product_name, _}, acc_products ->
      Map.update!(acc_products, product_name, fn product ->
        %{product | quantity: product.quantity + 10}
      end)
    end)
  end

  defp build_restock_order(products_to_restock) do
    Enum.map(products_to_restock, fn {product_name, _} ->
      {product_name, 10}
    end)
  end
