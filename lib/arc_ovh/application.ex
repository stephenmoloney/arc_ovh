defmodule ArcOvh.Application do
  @moduledoc :false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(ArcOvh.Client.Cloudstorage, []),
    ]
    opts = [strategy: :one_for_one, name: ArcOvh.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
