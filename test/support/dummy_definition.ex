  defmodule DummyDefinition do
    use Arc.Definition
    defp pseudofolder(), do: Application.get_env(:arc, :pseudofolder, "test_folder")

    # Whitelist file extensions:
    def validate({file, _}) do
      file_extension = file.file_name |> Path.extname() |> String.downcase()
      file_extension in ~w(.jpg .jpeg .gif .png)
    end
    def __storage(), do: Application.get_env(:arc, :storage, Arc.Storage.Ovh.Cloudstorage)
    def storage_dir(_, _), do: "#{pseudofolder()}"

end

