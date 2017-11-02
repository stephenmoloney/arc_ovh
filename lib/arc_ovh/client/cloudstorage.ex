defmodule ArcOvh.Client.Cloudstorage do
  @moduledoc :false
  use Openstex.Client, otp_app: :arc_ovh, client: __MODULE__

  defmodule Swift do
    @moduledoc :false
    use Openstex.Swift.V1.Helpers, otp_app: :arc_ovh, client: ArcOvh.Client.Cloudstorage
  end

  defmodule Ovh do
    @moduledoc :false
    use ExOvh.Client, otp_app: :arc_ovh, client: __MODULE__
  end
end
