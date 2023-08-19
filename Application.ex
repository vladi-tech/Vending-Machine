defmodule VendingMachineApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {VendingMachineApp.Building, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: VendingMachineApp.Supervisor)
  end

  def init(_args) do
    :ok = Application.ensure_all_started(:poolboy)

    # Configure the pool for floor workers
    floor_worker_pool_config = [
      name: {:local, :floor_worker_pool},
      worker_module: VendingMachineApp.FloorWorker,
      size: 3,
      max_overflow: 10
    ]
    Poolboy.child_spec(:floor_worker_pool, floor_worker_pool_config)

    # Return the supervisor tree
    children = [
      Poolboy.child_spec(:floor_worker_pool, []),
      {VendingMachineApp.FloorSupervisor, ["floor_1"]},
      {VendingMachineApp.FloorSupervisor, ["floor_2"]},
      {VendingMachineApp.FloorSupervisor, ["floor_3"]}
    ]

    supervise(children, strategy: :one_for_one)
  end
end

#The supervision tree includes:

#The :floor_worker_pool which is a pool of workers managed by Poolboy.
#Three instances of the VendingMachineApp.FloorSupervisor, each supervising a different floor.
#Other supervisors, such as the Building supervisor, can be added as needed.
