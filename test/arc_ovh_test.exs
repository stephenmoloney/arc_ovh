defmodule ArcOvhTest do
  use ArcOvh.TestCase, async: :false
  @client ArcOvh.Client.Cloudstorage

  test "Image can be stored as an upload to OVH public cloud storage" do
    DummyDefinition.store(image())
    server_objects = @client.swift().list_objects!(test_container())
    expected_server_object = "#{test_pseudofolder()}/#{Path.basename(image())}"
    expected_object_binary = File.read!(image())
    actual_object_binary = @client.swift().download_file!(expected_server_object, test_container())
    expected_image_size = original_image_size()
    downloaded_file_path = Path.join(tmp_path(), expected_server_object)
    File.touch!(downloaded_file_path) && File.write!(downloaded_file_path, actual_object_binary)
    actual_image_size = Fastimage.size(downloaded_file_path)

    assert(expected_server_object in server_objects)
    assert(expected_object_binary == actual_object_binary)
    assert(expected_image_size == actual_image_size)
  end


  test "Image can be resized and then stored as an upload to OVH public cloud storage" do
    DummyDefinitionResize.store(image())
    server_objects = @client.swift().list_objects!(test_container())
    expected_server_object = "#{test_pseudofolder()}/#{Path.basename(image())}"
    expected_object_binary = File.read!(image())
    actual_object_binary = @client.swift().download_file!(expected_server_object, test_container())
    expected_image_size = original_image_size()
    downloaded_file_path = Path.join(tmp_path(), expected_server_object)
    File.touch!(downloaded_file_path) && File.write!(downloaded_file_path, actual_object_binary)
    actual_image_size = Fastimage.size(downloaded_file_path)

    assert(expected_server_object in server_objects)
    refute(expected_object_binary == actual_object_binary)
    refute(expected_image_size == actual_image_size)
    assert(%{height: 100, width: 100} == actual_image_size)
  end


  test "Url generation for :original and :thumbnail, unsigned" do
    DummyDefinitionThumbnail.store({image(), %{id: 1}})
    public_url = @client.swift().get_public_url()
    actual_original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original)
    actual_thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail)

    expected_original_url =
    "#{public_url}/#{test_container()}/#{test_pseudofolder()}/" <>
    "#{1}/#{Path.basename(image()) |> Path.rootname()}_original#{Path.extname(image())}"

    expected_thumnbnail_url =
    "#{public_url}/#{test_container()}/#{test_pseudofolder()}/" <>
    "#{1}/#{Path.basename(image()) |> Path.rootname()}_thumbnail#{Path.extname(image())}"

    assert(expected_original_url == actual_original_url)
    assert(expected_thumnbnail_url == actual_thumbnail_url)
  end


  test "Url generation for :original and :thumbnail, signed" do
    DummyDefinitionThumbnail.store({image(), %{id: 1}})
    public_url = @client.swift().get_public_url()
    actual_original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original, signed: :true)
    actual_thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail, signed: :true)

    expected_original_binary = File.read!(image())
    actual_original_binary = HTTPipe.get!(actual_original_url) |> Map.get(:response) |> Map.get(:body)

    expected_original_url =
    "#{public_url}/#{test_container()}/#{test_pseudofolder()}/" <>
    "#{1}/#{Path.basename(image()) |> Path.rootname()}_original#{Path.extname(image())}"

    expected_thumnbnail_url =
    "#{public_url}/#{test_container()}/#{test_pseudofolder()}/" <>
    "#{1}/#{Path.basename(image()) |> Path.rootname()}_thumbnail#{Path.extname(image())}"

    assert(String.contains?(actual_original_url, expected_original_url))
    assert(String.contains?(actual_thumbnail_url, expected_thumnbnail_url))
    assert(expected_original_binary == actual_original_binary)
  end

  test "Image deletion" do
    {:ok, object_basename} = DummyDefinition.store({image(), %{id: 1}})
    server_object = "#{test_pseudofolder()}/#{object_basename}"
    object_exists_before_deletion? = object_exists?(server_object)

    :ok = DummyDefinition.delete({object_basename, %{id: 1}})
    :timer.sleep(300)

    object_exists_after_deletion? = object_exists?(server_object)
    assert(object_exists_before_deletion? == :true)
    assert(object_exists_after_deletion? == :false)
  end

  test "Url deletion, unsigned" do
    {:ok, object_basename} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
    actual_original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original)
    actual_thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail)

    original_server_object = actual_original_url |> String.split(test_container() <> "/") |> List.last()
    thumbnail_server_object = actual_thumbnail_url |> String.split(test_container() <> "/") |> List.last()

    object_exists_before_deletion_original? = object_exists?(original_server_object)
    object_exists_before_deletion_thumbnail? = object_exists?(thumbnail_server_object)

    :ok = DummyDefinitionThumbnail.delete({object_basename, %{id: 1}})
    :timer.sleep(300)

    object_exists_after_deletion_original? = object_exists?(original_server_object)
    object_exists_after_deletion_thumbnail? = object_exists?(thumbnail_server_object)

    assert(object_exists_before_deletion_original? == :true)
    assert(object_exists_before_deletion_thumbnail? == :true)
    assert(object_exists_after_deletion_original? == :false)
    assert(object_exists_after_deletion_thumbnail? == :false)
  end

  test "Url deletion, unsigned, without scope" do
    {:ok, _object_basename} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
    actual_original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original)
    actual_thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail)

    original_server_object = actual_original_url |> String.split(test_container() <> "/") |> List.last()
    thumbnail_server_object = actual_thumbnail_url |> String.split(test_container() <> "/") |> List.last()

    object_exists_before_deletion_original? = object_exists?(original_server_object)
    object_exists_before_deletion_thumbnail? = object_exists?(thumbnail_server_object)

    :ok = DummyDefinitionThumbnail.delete(actual_original_url)
    :ok = DummyDefinitionThumbnail.delete(actual_thumbnail_url)
    :timer.sleep(300)

    object_exists_after_deletion_original? = object_exists?(original_server_object)
    object_exists_after_deletion_thumbnail? = object_exists?(thumbnail_server_object)

    assert(object_exists_before_deletion_original? == :true)
    assert(object_exists_before_deletion_thumbnail? == :true)
    assert(object_exists_after_deletion_original? == :false)
    assert(object_exists_after_deletion_thumbnail? == :false)
  end


  test "Url deletion, signed" do
    {:ok, object_basename} = DummyDefinitionThumbnail.store({image(), %{id: 1}})
    actual_original_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :original, signed: :true)
    actual_thumbnail_url = DummyDefinitionThumbnail.url({image(), %{id: 1}}, :thumbnail, signed: :true)

    expected_original_binary = File.read!(image())
    actual_original_binary_before = HTTPipe.get!(actual_original_url) |> Map.get(:response)
    actual_thumbnail_binary_before = HTTPipe.get!(actual_thumbnail_url) |> Map.get(:response)
    thumbnail_size = Fastimage.size(actual_thumbnail_url)

    :ok = DummyDefinitionThumbnail.delete({object_basename, %{id: 1}})
    :timer.sleep(300)

    actual_original_binary_after = HTTPipe.get!(actual_original_url) |> Map.get(:response)
    actual_thumbnail_binary_after = HTTPipe.get!(actual_thumbnail_url) |> Map.get(:response)

    assert(expected_original_binary == Map.get(actual_original_binary_before, :body))
    assert(actual_original_binary_before.status_code == 200)
    assert(actual_thumbnail_binary_before.status_code == 200)
    assert(%{height: 100, width: 100} == thumbnail_size)
    assert(actual_original_binary_after.status_code == 404)
    assert(actual_thumbnail_binary_after.status_code == 404)
  end


  # private

  defp image(), do: Path.join(__DIR__, "./fixtures/bundoran.jpg") |> Path.expand()

  defp tmp_path(), do: Path.join(__DIR__, "./tmp") |> Path.expand()

  defp test_container(), do: Application.get_env(:arc, :container, "arc_ovh_test_container")

  defp test_pseudofolder(), do: Application.get_env(:arc, :pseudofolder, "arc_ovh")

  defp original_image_size(), do: Fastimage.size(image())

  defp object_exists?(object) do
    @client.swift().list_objects!(test_container())
    |> Enum.member?(object)
  end

end