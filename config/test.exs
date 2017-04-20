use Mix.Config

config :arc_ovh, ArcOvh.Client.Cloudstorage,
    adapter: Openstex.Adapters.Ovh,
    ovh: [
      application_key: System.get_env("APPLICATION_KEY_TEST"),
      application_secret: System.get_env("APPLICATION_SECRET_TEST"),
      consumer_key: System.get_env("CONSUMER_KEY_TEST")
    ],
    keystone: [
      tenant_id: System.get_env("TENANT_ID_TEST"), # mandatory, corresponds to an ovh project id or ovh servicename
      user_id: System.get_env("USER_ID_TEST"), # optional, if absent a user will be created using the ovh api.
      endpoint: "https://auth.cloud.ovh.net/v2.0"
    ],
    swift: [
      account_temp_url_key1: System.get_env("TEMP_URL_KEY1"), # defaults to :nil if absent
      account_temp_url_key2: System.get_env("TEMP_URL_KEY2"), # defaults to :nil if absent
      region: :nil
    ],
    hackney: [
      timeout: 20000,
      recv_timeout: 40000
    ]

config :httpipe,
  adapter: HTTPipe.Adapters.Hackney

config :arc,
  storage: Arc.Storage.Ovh.Cloudstorage,
  client: ArcOvh.Client.Cloudstorage,
  pseudofolder: "arc_ovh",
  container: "arc_ovh_test_container",
  default_tempurl_ttl: (30 * 24 * 60 * 60), # 30 days default time to live for signed urls.
  version_timeout: (60 * 3 * 1000) # 3 minutes
