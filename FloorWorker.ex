defmodule VendingMachineApp.FloorWorker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:restock, floor_name, machine_id, restock_order}, state) do
    IO.puts("The worker on floor #{floor_name} is restocking the machine #{machine_id}!")
    update_product_quantities(restock_order)
    {:noreply, state}
  end

  defp update_product_quantities(restock_order) do
    VendingMachineApp.Repo.transaction(fn ->
      Enum.each(restock_order, fn {product_name, quantity} ->
        IO.puts("Restocking #{product_name}")
        Process.sleep(250)
        VendingMachineApp.Product.decrease_quantity(product_name, quantity)
      end)
    end)
  end
end
