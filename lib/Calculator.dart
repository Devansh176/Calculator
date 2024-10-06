import 'dart:ui';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.access_time_rounded,
            color: Colors.white,
          ),
          onPressed: () => _showHistory(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 50.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10.0), // Adjust the space as needed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_controller.text.isNotEmpty) {
                                _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20.0),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          child: const Text(
                            'Backspace',
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 3,
                      padding: const EdgeInsets.all(15.0),
                      shrinkWrap: true,
                      children: [
                        buildOperationButton('C'),
                        buildOperationButton('%'),
                        buildOperationButton('/'),
                        buildOperationButton('*'),
                        buildNumButton('7'),
                        buildNumButton('8'),
                        buildNumButton('9'),
                        buildOperationButton('-'),
                        buildNumButton('4'),
                        buildNumButton('5'),
                        buildNumButton('6'),
                        buildOperationButton('+'),
                        buildNumButton('1'),
                        buildNumButton('2'),
                        buildNumButton('3'),
                        buildOperationButton('('),
                        buildOperationButton(')'),
                        buildNumButton('0'),
                        buildNumButton('.'),
                        buildEquals('='),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNumButton(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _controller.text += text;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 25.0,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildOperationButton(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (text == 'C') {
            _controller.clear();
          } else if (text == '+/-') {
            _toggleSign();
          } else {
            _controller.text += text;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(30.0),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 25.0,
          color: Colors.green,
        ),
      ),
    );
  }

  void _toggleSign() {
    String text = _controller.text;
    if (text.isEmpty) return;

    if (text.startsWith('-')) {
      _controller.text = text.substring(1);
    } else {
      _controller.text = '-$text';
    }
  }

  Widget buildEquals(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _evaluate();
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 25.0,
          color: Colors.lightGreenAccent,
        ),
      ),
    );
  }

  void _evaluate() {
    try {
      String input = _controller.text;
      input = input.replaceAll('x', '*').replaceAll('÷', '/');

      input = input.replaceAllMapped(RegExp(r'(\d+)%'), (Match m) => (double.parse(m[1]!) / 100).toString());

      final expression = Expression.parse(input);

      const evaluator = ExpressionEvaluator();
      final result = evaluator.eval(expression, {});

      _history.add('$input = $result');

      _controller.text = result.toString();
    } catch (e) {
      _controller.text = 'Error';
    }
  }

  void _showHistory(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          padding: const EdgeInsets.all(10.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                      title: Text(
                        _history[index],
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        );
      });
  }
}
