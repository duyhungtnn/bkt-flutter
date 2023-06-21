import 'package:bucketeer_example/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bucketeer/bucketeer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

const keyUserId = 'key_user_id';

Future<Map<String, String>> userMap() async {
  final uaData = await userAgentData();
  return {
    'platform': uaData.platform, // e.g.. 'Android'
    'platformVersion': uaData.platformVersion, // e.g.. '10'
    'device': uaData.device, // e.g.. 'coral'
    'appName': uaData.package.appName, // e.g.. 'SampleApp'
    'appVersion': uaData.package.appVersion, // e.g.. '1.0.0'
    'packageName': uaData.package.packageName, // e.g.. 'jp.wasabeef.ua'
    'buildNumber': uaData.package.buildNumber, // e.g.. '1'
  };
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class _AppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Bucketeer Demo'),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Bucketeer.instance.start();
    } else if (state == AppLifecycleState.paused) {
      Bucketeer.instance.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      // Generate UserId for Demo
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(keyUserId);
      if (userId == null) {
        await prefs.setString(
            keyUserId, 'demo-userId-${DateTime.now().millisecondsSinceEpoch}');
      }
      await Bucketeer.instance
        ..initialize(
            apiKey:
            '****************************************************************',
            apiEndpoint: '*********.bucketeer.jp',
            featureTag: 'Flutter',
            userId: userId!,
            debugging: true,
            eventsFlushInterval: 30000,
            eventsMaxQueueSize: 4,
            pollingInterval: 30000,
            backgroundPollingInterval: 60000,
            appVersion: "1.0.0"
        );
      await Bucketeer.instance.updateUserAttributes(userId, userMap: await userMap());
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flagController = TextEditingController(text: 'bucketeer-feature-flag');
  final goalController = TextEditingController(text: 'bucketeer-goal-id');
  final userIdController =
      TextEditingController(text: 'bucketeer-flutter-user-id');

  Future<void> _getStringVariation(String featureId) async {
    final result = await Bucketeer.instance
        .stringVariation(featureId, defaultValue: 'default value');
    result.ifSuccess((data) {
      print('getStringVariation: ${data}');
      showSnackbar(
          context: context, title: 'getStringVariation', message: data);
    });
  }

  Future<void> _getIntVariation(String featureId) async {
    final result =
        await Bucketeer.instance.intVariation(featureId, defaultValue: 0);
    result.ifSuccess((data) {
      print('getIntVariation: $data');
      showSnackbar(
          context: context, title: 'getIntVariation', message: '$data');
    });
  }

  Future<void> _getDoubleVariation(String featureId) async {
    final result = await Bucketeer.instance
        .doubleVariation(featureId, defaultValue: 0.0);
    result.ifSuccess((data) {
      print('getDoubleVariation: $data');
      showSnackbar(
          context: context, title: 'getDoubleVariation', message: '$data');
    });
  }

  Future<void> _getBoolVariation(String featureId) async {
    final result = await Bucketeer.instance
        .boolVariation(featureId, defaultValue: false);
    result.ifSuccess((data) {
      print('getBoolVariation: $data');
      showSnackbar(
          context: context, title: 'getBoolVariation', message: '$data');
    });
  }

  Future<void> _getEvaluation(String featureId) async {
    final result = await Bucketeer.instance.evaluationDetails(featureId);
    result.ifSuccess((evaluation) {
      print('Successful the evaluation');
      showSnackbar(
          context: context,
          title: 'getEvaluation(${evaluation.toString()})',
          message: 'Successful the evaluation.');
    });
  }

  Future<void> _sendGoal(String goalId) async {
    final result = await Bucketeer.instance.track(goalId, value: 3.1412);
    if (result.isSuccess) {
      print('Successful the send goal.');
      showSnackbar(
          context: context,
          title: 'sendGoal',
          message: 'Successful the send goal.');
    } else {
      print('Failed the send goal.');
      showSnackbar(
          context: context,
          title: 'sendGoal',
          message: 'Failed the send goal.');
    }
  }

  Future<void> _switchUser(String userId) async {
    // note: please initialize the Bucketeer again when switching the user
    await Bucketeer.instance
      ..initialize(
          apiKey:
          '****************************************************************',
          apiEndpoint: '*********.bucketeer.jp',
          featureTag: 'Flutter',
          userId: userId,
          debugging: true,
          eventsFlushInterval: 30000,
          eventsMaxQueueSize: 4,
          pollingInterval: 30000,
          backgroundPollingInterval: 60000,
          appVersion: "1.0.0"
      );
    var result = await Bucketeer.instance.updateUserAttributes(userId, userMap: await userMap());
    result.ifSuccess((_) {
      print('Successful the switchUser');
      showSnackbar(
          context: context,
          title: 'setUser',
          message: 'Successful the switchUser.');
    });
  }

  Future<void> _getCurrentUser() async {
    final result = await Bucketeer.instance.currentUser();
    result.ifSuccess((user) {
      print('Successful the getUser');
      showSnackbar(
          context: context,
          title: 'getUser(${user.id})',
          message: 'Successful the getUser.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 36.0),
                  Text(
                    'Feature Flag Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: flagController,
                    decoration:
                        InputDecoration(hintText: 'bucketeer-feature-flag'),
                  ),
                  const SizedBox(height: 12),
                  Text('GET VARIATION',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                          child: Text('GET String param'),
                          onPressed: () async {
                            return _getStringVariation(flagController.text);
                          }),
                      TextButton(
                          child: Text('GET int param'),
                          onPressed: () async {
                            return _getIntVariation(flagController.text);
                          }),
                      TextButton(
                          child: Text('GET double params'),
                          onPressed: () async {
                            return _getDoubleVariation(flagController.text);
                          }),
                      TextButton(
                          child: Text('GET bool params'),
                          onPressed: () async {
                            return _getBoolVariation(flagController.text);
                          }),
                      TextButton(
                          child: Text('GET evalution'),
                          onPressed: () async {
                            return _getEvaluation(flagController.text);
                          }),
                    ],
                  ),
                  SizedBox(height: 36.0),
                  Text(
                    'Goal Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: goalController,
                    decoration: InputDecoration(hintText: goalController.text),
                  ),
                  TextButton(
                      child: Text('SEND GOAL'),
                      onPressed: () async {
                        return _sendGoal(goalController.text);
                      }),
                  SizedBox(height: 36.0),
                  Text(
                    'User Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: userIdController,
                    decoration:
                        InputDecoration(hintText: userIdController.text),
                  ),
                  Row(
                    children: [
                      TextButton(
                          child: Text('SWITCH USER'),
                          onPressed: () async {
                            return _switchUser(userIdController.text);
                          }),
                      TextButton(
                        child: Text('GET CURRENT USER'),
                        onPressed: () async {
                          return _getCurrentUser();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
