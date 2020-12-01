defmodule SensorHubWeb.MonitorLive do
  use SensorHubWeb, :live_view
  use Bitwise

  @refresh_interval 1000

  @sensor_status_codes [
    # l_fail == 1
    "Light Brightness Not Found",
    # l_ovr == 1
    "Light Brightness Overflow",
    # t_fail == 1
    "Ext. Temperature Not Found",
    # t_ovr == 1
    "Ext. Temperature Overflow"
  ]

  def mount(_params, _session, socket) do
    socket = assign(socket, raw_data: SensorHub.DataReader.get_data())

    # refresh itself every second
    schedule_refresh()

    {:ok, socket}
  end

  def handle_info(:refresh, socket) do
    socket = assign(socket, raw_data: SensorHub.DataReader.get_data())

    schedule_refresh()

    {:noreply, socket}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  ### Helpers (for raw data structure see SensorHub.DataReader)

  defp status(%{status: 0}), do: "Ok"
  defp status(%{status: n}), do: interpret_bit_status(<<n>>)
  defp status(_), do: "Unknown"

  # see https://wiki.52pi.com/index.php/DockerPi_Sensor_Hub_Development_Board_SKU:_EP-0106#Register_Map
  defp interpret_bit_status(
         <<_reserved::size(4), l_fail::size(1), l_ovr::size(1), t_fail::size(1), t_ovr::size(1)>>
       ) do
    Enum.zip([
      [l_fail, l_ovr, t_fail, t_ovr],
      @sensor_status_codes
    ])
    |> Enum.map_join(fn
      {1, code} -> code
      {0, _} -> ""
    end)
  end

  defp bpm_status(%{bpm280_status: 0}), do: "Ok"
  defp bpm_status(%{bpm280_status: 1}), do: "Error"

  defp human_detector(%{human_detect: 0}), do: "No active body"
  defp human_detector(%{human_detect: 1}), do: "Active body"

  defp concat_light(%{
         light_high: high,
         light_low: low
       }),
       do: (high <<< 8) + low

  defp concat_pressure(%{
         bpm280_pressure_high: high,
         bpm280_pressure_medium: med,
         bpm280_pressure_low: low
       }),
       do: (high <<< 16) + (med <<< 8) + low
end
