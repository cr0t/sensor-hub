defmodule SensorHub.DataReader do
  @moduledoc """
  Opens the first I2C bus ("i2c-1") and reads from SensorHub device address (0x17).

  Updates its internal state periodically (every second in the example below).

  Below you can find a table of registers, that we found on their website:
  https://wiki.52pi.com/index.php/DockerPi_Sensor_Hub_Development_Board_SKU:_EP-0106

  Register Address  Function                 Value
  0x01              TEMP_REG                 Ext. Temperature [Unit:degC]
  0x02              LIGHT_REG_L              Light Brightness Low 8 Bit [Unit:Lux]
  0x03              LIGHT_REG_H              Light Brightness High 8 Bit [Unit:Lux]
  0x04              STATUS_REG               Status Function
  0x05              ON_BOARD_TEMP_REG        OnBoard Temperature [Unit:degC]
  0x06              ON_BOARD_HUMIDITY_REG    OnBoard Humidity [Uinit:%]
  0x07              ON_BOARD_SENSOR_ERROR    0(OK) - 1(Error)
  0x08              BMP280_TEMP_REG  P.      Temperature [Unit:degC]
  0x09              BMP280_PRESSURE_REG_L    P. Pressure Low 8 Bit [Unit:Pa]
  0x0A              BMP280_PRESSURE_REG_M    P. Pressure Mid 8 Bit [Unit:Pa]
  0x0B              BMP280_PRESSURE_REG_H    P. Pressure High 8 Bit [Unit:Pa]
  0x0C              BMP280_STATUS            0(OK) - 1(Error)
  0x0D              HUMAN_DETECT             0(No Active Body) - 1(Active Body)
  """

  alias Circuits.I2C

  @bus_name "i2c-1"
  @sensor_hub_addr 0x17

  use GenServer

  ### External API

  def start_link(_) do
    {:ok, _} = GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def get_data() do
    GenServer.call(__MODULE__, :data)
  end

  ### GenServer API

  def init(_initial) do
    {:ok, bus} = I2C.open(@bus_name)
    {:ok, data} = get_sensors_data(bus)

    {:ok, {bus, data}}
  end

  def handle_call(:data, _from, {bus, _data}) do
    new_data = get_sensors_data(bus)

    {:reply, new_data, {bus, new_data}}
  end

  ### Helper functions

  defp get_sensors_data(bus) do
    {:ok,
     <<0, ext_temp, light_low, light_high, status, on_board_temp, on_board_humidity,
       on_board_error, bpm280_temp, bpm280_pressure_low, bpm280_pressure_medium,
       bpm280_pressure_high, bpm280_status,
       human_detect>>} = I2C.write_read(bus, @sensor_hub_addr, <<0>>, 0x0E)

    {:ok,
     %{
       external_temp: ext_temp,
       light_low: light_low,
       light_high: light_high,
       status: status,
       on_board_temp: on_board_temp,
       on_board_humidity: on_board_humidity,
       on_board_error: on_board_error,
       bpm280_temp: bpm280_temp,
       bpm280_pressure_low: bpm280_pressure_low,
       bpm280_pressure_medium: bpm280_pressure_medium,
       bpm280_pressure_high: bpm280_pressure_high,
       bpm280_status: bpm280_status,
       human_detect: human_detect
     }}
  end
end
