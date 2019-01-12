package lwj.serialport;

import android.util.Log;

import com.deemons.serialportlib.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.Observer;
import java.util.concurrent.TimeUnit;


import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;




/** SerialPortPlugin */
public class SerialPortPlugin implements MethodCallHandler,EventChannel.StreamHandler {
    private SerialPort mSerialPort;
    private SerialPortFinder serialPortFinder;
    private boolean isInterrupted ;
    private OutputStream os;
    private InputStream is;
    private String TAG = "SerialPortPlugin";
    private EventChannel.EventSink m_EventSink;


    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "serial_port");

        channel.setMethodCallHandler(new SerialPortPlugin(registrar));
    }

    SerialPortPlugin(Registrar registrar){
        final EventChannel  eventChannel = new EventChannel(registrar.messenger(),"serial_event");
        eventChannel.setStreamHandler(this);
    }
    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method){
            case  "findSerialPort":
                this.serialPortFinder = new SerialPortFinder();
//            String[] allDevices =  this.serialPortFinder.getAllDevices();
                String[] allDevicesPath = this.serialPortFinder.getAllDevicesPath();
//        System.out.println(allDevicesPath);
                //数组转成List
                result.success(Arrays.asList(allDevicesPath));
                //数组转成string
//      result.success(Arrays.toString(allDevicesPath));
                break;
            case "openSerialPort":
                try {
                    this.mSerialPort =  new SerialPort((String)call.argument("name"),(int)call.argument("rate"));
//                    this.mSerialPort =  new SerialPort("/dev/ttyS0",19200);
                } catch (IOException e) {
                    result.success("缺少权限");
                    e.printStackTrace();
                    this.mSerialPort = null;
                }
                if(this.mSerialPort != null){
                    this.isInterrupted = true;

                }else{
                    result.success("打开失败");
                }
                this.is = this.mSerialPort.getInputStream();
                this.os = this.mSerialPort.getOutputStream();
                new ReadThread().start();
                result.success("运行中...");

                break;
            case "writeSerialPort":
                try {
                    this.os.write(ByteUtils.hexStringToBytes(call.argument("str")));
//                    this.os.write(DataUtils.HexToByteArr(call.argument("str")));  只能发送数字
                    result.success(call.argument("str"));
                } catch (IOException e) {
                    e.printStackTrace();
                    result.success("写入失败");
                }

                break;
            case "closeSerialPort":
                if(!this.isInterrupted)result.success("关闭");
                try {
                    os.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }

//                this.mSerialPort.close();
                this.isInterrupted = false;
                result.success("关闭");
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
        }
//      result.notImplemented();
    }

    @Override
    public void onListen(Object o, EventSink eventSink) {
        Log.w(TAG, "adding listener a"+eventSink);
        this.m_EventSink = eventSink;
//        this.isInterrupted = true;
//        try {
//            this.mSerialPort =  new SerialPort("/dev/ttyS0",19200);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        this.is = this.mSerialPort.getInputStream();
//        this.os = this.mSerialPort.getOutputStream();

//        Log.d(TAG,"x"+this.isInterrupted);

//        eventSink.success(mReceiveDisposable);

    }


    @Override
    public void onCancel(Object o) {
        m_EventSink = null;
    }
    private class ReadThread extends Thread{
        @Override
        public void run() {
            super.run();
            //判断进程是否在运行，更安全的结束进程
            while (isInterrupted){
                Log.d(TAG, "进入线程run");
                //64   1024
                byte[] buffer = new byte[1024];
                int size; //读取数据的大小
                try {
                    size = is.read(buffer);
                    if (size > 0){
                        Log.d(TAG, "run: 接收到了数据：" + DataUtils.ByteArrToHex(buffer,0,size));
                        Log.d(TAG, "run: 接收到了数据大小：" + String.valueOf(size));
                        String readString = DataUtils.ByteArrToHex(buffer,0,size);
                        if(m_EventSink!=null){
                            m_EventSink.success(readString);
                        }else{
                            Log.d(TAG,"is null");
                        }
                    }
                } catch (IOException e) {
                    Log.e(TAG, "run: 数据读取异常：" +e.toString());
                }
            }
        }
    }

}

