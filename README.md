# ArcOvh

Use Arc with the [OVH Cloudstorage](https://www.ovh.co.uk/public-cloud/storage/)


## Installation

The package can be installed by adding `arc_ovh` to your
list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:arc_ovh, "~> 0.2"}]
end
```


## Configuration

  - Configure the Arc Storage adapter
```elixir
config :arc,
  storage: Arc.Storage.Ovh.Cloudstorage,
  client: ArcOvh.Client.Cloudstorage,
  container: "default",
  default_tempurl_ttl: (30 * 24 * 60 * 60), # 30 days default time to live for signed urls.
  version_timeout: (60 * 3 * 1000) # 3 minutes
```

  - Configure the OVH client
```elixir
config :arc_ovh, ArcOvh.Client.Cloudstorage,
    adapter: Openstex.Adapters.Ovh,
    ovh: [
      application_key: System.get_env("APPLICATION_KEY"),
      application_secret: System.get_env("APPLICATION_SECRET"),
      consumer_key: System.get_env("CONSUMER_KEY")
    ],
    keystone: [
      tenant_id: System.get_env("TENANT_ID"), # mandatory, corresponds to an ovh project id or ovh servicename
      user_id: System.get_env("USER_ID"), # optional, if absent a user will be created using the ovh api.
      endpoint: "https://auth.cloud.ovh.net/v2.0"
    ],
    swift: [
      account_temp_url_key1: System.get_env("TEMP_URL_KEY1"), # defaults to :nil if absent
      account_temp_url_key2: System.get_env("TEMP_URL_KEY2"), # defaults to :nil if absent
      region: :nil # specify a region if you like. Check your OVH cloud.
    ],
    hackney: [
      timeout: 20000,
      recv_timeout: 40000
    ]

config :httpipe,
  adapter: HTTPipe.Adapters.Hackney
```


## Example usage

  - Create Definition (see [arc](https://github.com/stavro/arc) for more information)

```elixir
defmodule DummyDefinitionThumbnail do
    use Arc.Definition
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
       "#{scope.id}" ||
       ""
    end
    def storage_dir(_version, _) do
       ""
    end

    def filename(version, {file, _scope}) do
      "#{Path.basename(file.file_name) |> Path.rootname()}_#{version}"
    end
end
```

   - Store an image and generate a url for the
   `:original` version and `:thumbnail` version

```elixir
defp image(), do: Path.join(__DIR__, "./assets/image.jpg") |> Path.expand()

{:ok, object_name} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original)
thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail)
```

   - Store an image and generate a signed url for the
   `:original` version and `:thumbnail` version

```elixir
defp image(), do: Path.join(__DIR__, "./assets/image.jpg") |> Path.expand()

{:ok, object_name} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
original_signed_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original, signed: :true)
thumbnail_signed_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail, signed: :true)
```

   - Delete an image for all versions.

```elixir
{:ok, object_name} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
:ok = DummyDefinitionThumbnail.delete({object_name, %{id: 1}})
```


## Tests

- Tests are run against a container named `arc_ovh_test_container` on an ovh
openstack server.

- Create a `test.exs` file in `config.exs` and setup a [Configuration](## Configuration)

- `mix test`

- The image used in the tests was taken in bundoran Ireland by me a few years back.

<p align="center">
  <img src="https://github.com/stephenmoloney/arc_ovh/blob/master/test/fixtures/bundoran.jpg?raw=true" width="600">
</p>



## License

[MIT Licence](LICENSE)
