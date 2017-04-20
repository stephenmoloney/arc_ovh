defmodule DummyDefinitionThumbnail do
    use Arc.Definition
    defp pseudofolder(), do: Application.get_env(:arc, :pseudofolder, "test_folder")
    @versions [:original, :thumbnail]

    def transform(:thumbnail, _) do
      {"convert", "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format jpg", :jpg}
    end
    # Whitelist file extensions:
    def validate({file, _}) do
      file_extension = file.file_name |> Path.extname() |> String.downcase()
      file_extension in ~w(.jpg .jpeg .gif .png)
    end
    def __storage(), do: Application.get_env(:arc, :storage, Arc.Storage.Ovh.Cloudstorage)

    def storage_dir(_version, {_file, scope}) do
      (scope != :nil && Map.has_key?(scope, :id)) &&
       "#{pseudofolder()}/#{scope.id}" ||
       "#{pseudofolder()}"
    end
    def storage_dir(_version, _) do
       "#{pseudofolder()}"
    end

    def filename(version, {file, _scope}) do
      "#{Path.basename(file.file_name) |> Path.rootname()}_#{version}"
    end

end

