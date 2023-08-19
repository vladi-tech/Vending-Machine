defmodule VendingMachineApp.Client do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_state) do
    {:ok, %{}}
  end

  def send_order(order) do
    floor_supervisor_pid = VendingMachineApp.BuildingSupervisor.get_floor_supervisor_pid()
    GenServer.cast(floor_supervisor_pid, {:order_request, order})
  end

  def get_recommendation(product_type) do
    floor_supervisor_pid = VendingMachineApp.BuildingSupervisor.get_floor_supervisor_pid()
    GenServer.cast(floor_supervisor_pid, {:recommendation_request, product_type})
  end

end
