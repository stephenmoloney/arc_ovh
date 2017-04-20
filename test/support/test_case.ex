defmodule ArcOvh.TestCase do
  @moduledoc :false
  use ExUnit.CaseTemplate, async: :false
  alias Openstex.Swift.V1
  @client ArcOvh.Client.Cloudstorage
  @tmp_path Path.join(__DIR__, "../tmp") |> Path.expand()

  setup() do
    {:ok, containers} = @client.swift().list_containers()
    (containers == []) && create_container!()
    {:ok, containers} = @client.swift().list_containers()
    (not test_container() in containers) && create_container!()
    :ok = Path.join(@tmp_path, test_pseudofolder()) |> File.mkdir_p!()
    on_exit(fn() ->
      delete_container!()
      File.rm_rf!(@tmp_path)
    end)
    :ok
  end

  # private
  defp test_container(), do: Application.get_env(:arc, :container, "arc_ovh_test_container")
  defp test_pseudofolder(), do: Application.get_env(:arc, :pseudofolder, "arc_ovh")

  defp create_container!() do
    V1.create_container(test_container(), @client.swift().get_account())
    |> @client.request!()
  end

  defp delete_container!() do
    @client.swift().delete_pseudofolder(test_pseudofolder(), test_container())
    V1.delete_container(test_container(), @client.swift().get_account())
    |> @client.request!()
  end

end
