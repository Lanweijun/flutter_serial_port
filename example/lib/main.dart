import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:serial_port/serial_port.dart';

void main() => runApp(new HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> baudRate = [9600, 14400, 19200, 28800];
  List<dynamic> serialPorts = ['串口获取失败'];
  String deBaudRate = '19200';
  String dePort = '串口获取失败';
  List<String> getStr = [];
  String portStatus = '关闭';
  String writeStatus = '未写入';
  String writeData;
  String getData = '';
  String newMsg ='';

//  获取串口列表
  _findPorts() async {
    var port;
    try {
      port = await SerialPort.findSerialPort();
      serialPorts = port.length > 0 ? port : serialPorts;
      dePort = serialPorts[0];
    } on PlatformException {
      port = '获取失败';
    }
//    print(json.);
//    print(serialPorts);
    setState(() {});
  }

  // 打开串口
  _openSerialPort() async {
    try {
      portStatus =
          await SerialPort.openSerialPort(dePort, int.parse(deBaudRate));
      SerialPort.listenSerialPort((data) {
        newMsg += data;
        RegExp msgReg = new RegExp(r"^AAAA.*1F1F$");

        if(msgReg.hasMatch(newMsg)){
          getData = newMsg;
          newMsg = '';
        }
        print(newMsg);

        setState(() {

        });
      });
    } on PlatformException {
      portStatus = '打开失败';
    }
    print(portStatus);
    setState(() {});
  }

  //关闭串口
  _closeSerialPort() async {
    try {
      portStatus = await SerialPort.closeSerialPort();
    } on PlatformException {
      portStatus = '关闭失败';
    }
    setState(() {});
  }

  //写入数据
  _writePutData(String str) async {
    var state;
    try {
      state = await SerialPort.writeSerialPort(str);
      writeStatus = state;
    } on PlatformException {
      writeStatus = '写入失败！';
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _findPorts();
    dePort = serialPorts.length > 0 ? serialPorts[0] : '串口获取失败';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'serial test',
        theme: ThemeData.dark(),
        home: Scaffold(
            appBar: AppBar(
              title: Text('串口测试'),
            ),
            body: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10.0),
                        Text('串口运行状态：$portStatus'),
                        Text('串口写入状态：$writeStatus'),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.usb,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                    ),
                                    Text('串口:',
                                        style: TextStyle(color: Colors.green)),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: PopupMenuButton(
                                  child: Text(
                                    dePort,
                                    textAlign: TextAlign.right,
                                  ),
                                  itemBuilder: (BuildContext context) {
                                    return serialPorts.map((i) {
                                      return new PopupMenuItem(
                                        child: Text(i),
                                        value: i,
                                      );
                                    }).toList();
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      dePort = value;
                                    });
                                  },
                                ))
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.graphic_eq,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                    ),
                                    Text('波特率:',
                                        style: TextStyle(
                                            color: Colors.lightGreenAccent)),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: PopupMenuButton(
                                  child: Text(
                                    deBaudRate,
                                    textAlign: TextAlign.right,
                                  ),
                                  itemBuilder: (BuildContext context) {
                                    return baudRate.map((i) {
                                      return new PopupMenuItem(
                                        child: Text(i.toString()),
                                        value: i,
                                      );
                                    }).toList();
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      deBaudRate = value.toString();
                                    });
                                  },
                                ))
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                              hintText: "请输入所需发送的数据",
                              border: OutlineInputBorder()),
                          onSubmitted: (value) {
                            writeData = value;
                            print('submit' + value);
                          },
                          onChanged: (value) {
                            writeData = value;
                            print('change' + value);
                          },
                        ),
                        const SizedBox(height: 10.0),
                        Row(
//                    mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            RaisedButton(
                              child: Text('打开串口'),
                              onPressed: _openSerialPort,
                            ),
                            RaisedButton(
                                child: Text('关闭串口'),
                                onPressed: _closeSerialPort)
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              child: Text('发送数据'),
                              onPressed: () {
                                _writePutData(writeData);
                              },
                            )
                          ],
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(getData),
                )
              ],
            )));
  }
}
