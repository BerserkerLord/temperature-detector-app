import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(app: app, title: 'Flutter Demo')));
}

class MyHomePage extends StatefulWidget {
  final FirebaseApp app;

  const MyHomePage({Key? key, required this.title, required this.app})
      : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestor de Temperatura"),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("PIC_DEVICE").onValue,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         var databaseEvent = snapshot.data!;
         var databaseSnapshot = databaseEvent.snapshot;
          return Container(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(

                          ticksPosition: ElementsPosition.outside,
                          labelsPosition: ElementsPosition.outside,
                          minorTicksPerInterval: 5,
                          axisLineStyle: AxisLineStyle(
                            thicknessUnit: GaugeSizeUnit.factor,
                            thickness: 0.1,
                          ),
                          axisLabelStyle: GaugeTextStyle(

                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          radiusFactor: 0.97,
                          majorTickStyle: MajorTickStyle(
                              length: 0.1,
                              thickness: 2,

                              lengthUnit: GaugeSizeUnit.factor),
                          minorTickStyle: MinorTickStyle(
                              length: 0.05,
                              thickness: 1.5,

                              lengthUnit: GaugeSizeUnit.factor),
                          minimum: -60,
                          maximum: 120,
                          interval: 20,
                          startAngle: 115,
                          endAngle: 65,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: -60,
                                endValue: 120,
                                startWidth: 0.1,
                                sizeUnit: GaugeSizeUnit.factor,
                                endWidth: 0.1,
                                gradient: SweepGradient(stops: <double>[
                                  0.2,
                                  0.5,
                                  0.75
                                ], colors: <Color>[
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.red
                                ]))
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(
                                value: double.parse(databaseSnapshot.child("temp").child("data").value), needleColor: Colors.black,
                                tailStyle: TailStyle(length: 0.18, width: 8,
                                    color: Colors.black,
                                    lengthUnit: GaugeSizeUnit.factor),
                                needleLength: 0.68,
                                needleStartWidth: 1,
                                needleEndWidth: 8,
                                knobStyle: KnobStyle(knobRadius: 0.07,
                                    color: Colors.white, borderWidth: 0.05,
                                    borderColor: Colors.black),
                                lengthUnit: GaugeSizeUnit.factor)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Text(
                                  '${databaseSnapshot.child("temp").child("data").value} °C',
                                  style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                ),
                                positionFactor: 0.8,
                                angle: 90)
                          ],
                        ),
                      ],
                    ),

                  ),
                ),
                TextButton(onPressed: (){
                  if(databaseSnapshot.child("on").child("data").value == 0){
                    FirebaseDatabase.instance.ref("PIC_DEVICE/on/data").set(1);
                    print(databaseSnapshot.child("on").child("data").value);
                  }
                  else{
                    FirebaseDatabase.instance.ref("PIC_DEVICE/on/data").set(0);
                    print(databaseSnapshot.child("on").child("data").value);
                  }
                },
                child: Text(databaseSnapshot.child("on").child("data").value == 0 ? "Encender" : "Apagar"))
              ],
            )
          );
        },
      ),
    );
  }
}