import QtQuick 2.0

Rectangle {
    implicitWidth: 500;
    implicitHeight: 120;
    color: "#404040";

    Grid{
        columns: 3;
        spacing: 0;
        Grid{
            columns: 1;
            spacing: 0;
            BottomRect{
                textLabel: "采样率： 100Sps";
            }
            BottomRect{
                textLabel: "采集模式： 时长采集";
            }
            BottomRect{
                textLabel: "触发模式： 内部触发";
            }
            BottomRect{
                textLabel: "时钟模式： 内部时钟";
            }
        }
        Grid{
            columns: 1;
            spacing: 0;
            BottomRect{
                textLabel: "中心频率： 100MHz";
            }
            BottomRect{
                textLabel: "双测带宽： 100MHz";
            }
            BottomRect{
                textLabel: "Mark幅度： -10dB";
            }
            BottomRect{
                textLabel: "频域分辨率： 1KHz";
            }
        }
        Grid{
            columns: 1;
            spacing: 0;
            BottomRect{
                textLabel: "工作模式： 本地模式";
            }
            BottomRect{
                textLabel: "存储模式： 本地模式";
            }
        }
    }
}
