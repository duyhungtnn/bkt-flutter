import 'package:bucketeer_example/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

import 'constant.dart';

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

class _AppState extends State<MyApp>
    with WidgetsBindingObserver
    implements BKTEvaluationUpdateListener {
  late final String _listenToken;

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
  void initState() {
    super.initState();
    Future(() async {
      // Generate UserId for Demo
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString(keyUserId);
      if (userId == null) {
        userId = 'demo-userId-${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(keyUserId, userId);
      }
      final config = BKTConfigBuilder()
          .apiKey(Constants.API_KEY)
          .apiKey(Constants.API_ENDPOINT)
          .featureTag(Constants.EXAMPLE_FEATURE_TAG)
          .debugging(true)
          .eventsMaxQueueSize(Constants.EXAMPLE_EVENT_MAX_QUEUE_SIZE)
          .eventsFlushInterval(Constants.EXAMPLE_EVENTS_FLUSH_INTERVAL)
          .pollingInterval(Constants.EXAMPLE_POLLING_INTERVAL)
          .backgroundPollingInterval(
              Constants.EXAMPLE_BACKGROUND_POLLING_INTERVAL)
          .appVersion("1.0.0")
          .build();
      final user =
          BKTUserBuilder().id(userId).data({'app_version': "1.2.3"}).build();
      await BKTClient.instance.initialize(config: config, user: user);
      _listenToken = BKTClient.instance.addEvaluationUpdateListener(this);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    BKTClient.instance.removeEvaluationUpdateListener(_listenToken);
  }

  @override
  void onUpdate() {
    // EvaluationUpdateListener onUpdate()
    debugPrint("EvaluationUpdateListener.onUpdate() called");
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flagController =
      TextEditingController(text: Constants.EXAMPLE_FEATURE_TAG);
  final goalController = TextEditingController(text: 'bucketeer-goal-id');
  final userIdController =
      TextEditingController(text: Constants.EXAMPLE_USERID);

  Future<void> _getStringVariation(String featureId) async {
    final result = await BKTClient.instance
        .stringVariation(featureId, defaultValue: 'default value');
    result.ifSuccess((data) {
      print('getStringVariation: ${data}');
      showSnackbar(
          context: context, title: 'getStringVariation', message: data);
    });
  }

  Future<void> _getIntVariation(String featureId) async {
    final result =
        await BKTClient.instance.intVariation(featureId, defaultValue: 0);
    result.ifSuccess((data) {
      print('getIntVariation: $data');
      showSnackbar(
          context: context, title: 'getIntVariation', message: '$data');
    });
  }

  Future<void> _getDoubleVariation(String featureId) async {
    final result =
        await BKTClient.instance.doubleVariation(featureId, defaultValue: 0.0);
    result.ifSuccess((data) {
      print('getDoubleVariation: $data');
      showSnackbar(
          context: context, title: 'getDoubleVariation', message: '$data');
    });
  }

  Future<void> _getBoolVariation(String featureId) async {
    final result =
        await BKTClient.instance.boolVariation(featureId, defaultValue: false);
    result.ifSuccess((data) {
      print('getBoolVariation: $data');
      showSnackbar(
          context: context, title: 'getBoolVariation', message: '$data');
    });
  }

  Future<void> _getJSONVariation(String featureId) async {
    final result =
        await BKTClient.instance.jsonVariation(featureId, defaultValue: {});
    result.ifSuccess((data) {
      print('getJSONVariation: $data');
      showSnackbar(
          context: context, title: 'getJSONVariation', message: '$data');
    });
  }

  Future<void> _getEvaluation(String featureId) async {
    final result = await BKTClient.instance.evaluationDetails(featureId);
    result.ifSuccess((evaluation) {
      print('Successful the evaluation');
      showSnackbar(
          context: context,
          title: 'getEvaluation(${evaluation.toString()})',
          message: 'Successful the evaluation.');
    });
  }

  Future<void> _sendGoal(String goalId) async {
    final result = await BKTClient.instance.track(goalId, value: 3.1412);
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
    final config = BKTConfigBuilder()
        .apiKey(Constants.API_KEY)
        .apiKey(Constants.API_ENDPOINT)
        .featureTag(Constants.EXAMPLE_FEATURE_TAG)
        .debugging(true)
        .eventsMaxQueueSize(Constants.EXAMPLE_EVENT_MAX_QUEUE_SIZE)
        .eventsFlushInterval(Constants.EXAMPLE_EVENTS_FLUSH_INTERVAL)
        .pollingInterval(Constants.EXAMPLE_POLLING_INTERVAL)
        .backgroundPollingInterval(
            Constants.EXAMPLE_BACKGROUND_POLLING_INTERVAL)
        .appVersion("1.0.0")
        .build();
    final user =
        BKTUserBuilder().id(userId).data({'app_version': "1.2.3"}).build();

    await BKTClient.instance.destroy();
    await BKTClient.instance.initialize(
      config: config,
      user: user,
    );
    var result = await BKTClient.instance.updateUserAttributes(
      userAttributes: {'app_version': "1.2.4"},
    );
    result.ifSuccess((rs) {
      print('Successful the switchUser');
      showSnackbar(
          context: context,
          title: 'setUser',
          message: 'Successful the switchUser.');
    });
    result.ifFailure((message) {
      print('Fail to update user info ${message}');
    });
  }

  Future<void> _getCurrentUser() async {
    final result = await BKTClient.instance.currentUser();
    result.ifSuccess((user) {
      print('Successful the getUser');
      showSnackbar(
          context: context,
          title: 'getUser(${user.id})',
          message: '${user.data.toString()}');
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
                          child: Text('GET json params'),
                          onPressed: () async {
                            return _getJSONVariation(flagController.text);
                          }),
                      TextButton(
                          child: Text('GET evaluation'),
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
