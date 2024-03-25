import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';  
import 'package:quiver/iterables.dart';   //DO NOT CHANGE IN THE FILE
import 'package:sudoku_clg/blokChar.dart';
import 'package:sudoku_clg/boxInner.dart';
import 'package:sudoku_clg/focusClass.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';   //DO NOT CHANGE IN THE FILE

class SudokuWidget extends StatefulWidget { 
  const SudokuWidget({Key? key}) : super(key: key);

  @override
  State<SudokuWidget> createState() => _SudokuWidgetState();
}

class _SudokuWidgetState extends State<SudokuWidget> {
  // our variable

  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinish = false;
  String? tapBoxIndex;

  //timer and round count
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _timerText = '00:00:00';
  int _roundCount = 0; // Add this variable to track round count

  @override
  void initState() {
    generateSudoku();
    _startTimer(); // Start the timer when the puzzle is generated
    // TODO: implement initState
    super.initState();
  }

  void _startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _timerText = _formatTime(_stopwatch.elapsedMilliseconds ~/ 1000);
    });
  });
  _stopwatch.start();
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void generateSudoku() {
    isFinish = false;
    focusClass = new FocusClass();
    tapBoxIndex = null;
    generatePuzzle();
    checkFinish();
    _roundCount++;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // lets put on ui

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Round: $_roundCount'),
                const SizedBox(width: 18),
                Text(_timerText),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () => generateSudoku(), child: const Icon(Icons.refresh)),
        ],
      ),
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                // height: 400,
                color: Colors.blueGrey,
                padding: EdgeInsets.all(5),
                width: double.maxFinite,
                alignment: Alignment.center,
                child: GridView.builder(
                  itemCount: boxInners.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  physics: ScrollPhysics(),
                  itemBuilder: (buildContext, index) {
                    BoxInner boxInner = boxInners[index];

                    return Container(
                      color: Colors.red.shade100,
                      alignment: Alignment.center,
                      child: GridView.builder(
                        itemCount: boxInner.blokChars.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),

                        physics: ScrollPhysics(),
                        itemBuilder: (buildContext, indexChar) {
                          BlokChar blokChar = boxInner.blokChars[indexChar];
                          Color color = Colors.yellow.shade100;
                          Color colorText = Colors.black;

                        // Change color base condition

                          if (isFinish)
                            color = Colors.green;
                          else if (blokChar.isFocus && blokChar.text != "")
                            color = Colors.brown.shade100;
                          else if (blokChar.isDefault)
                            color = Colors.grey.shade400;

                          if (tapBoxIndex == "${index}-${indexChar}" &&
                              !isFinish) color = Colors.blue.shade100;

                          if (this.isFinish)
                            colorText = Colors.white;
                          else if (blokChar.isExist) colorText = Colors.red;

                          return Container(
                            color: color,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: blokChar.isDefault
                                  ? null
                                  : () => setFocus(index, indexChar),
                              child: Text(
                                "${blokChar.text}",
                                style: TextStyle(color: colorText),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: GridView.builder(
                          itemCount: 9,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          physics: ScrollPhysics(),
                          itemBuilder: (buildContext, index) {
                            return ElevatedButton(
                              onPressed: () => setInput(index + 1),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: ElevatedButton(
                            onPressed: () => setInput(null),
                            child: Container(
                              child: Text(
                                "Clear",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  generatePuzzle() {
    // install plugins sudoku generator to generate one
    boxInners.clear(); 
    var sudokuGenerator = SudokuGenerator(emptySquares: 1); //54
    // then we populate to get a possible combination
    // Quiver for easy populate collection using partition
    List<List<List<int>>> completes = partition(sudokuGenerator.newSudokuSolved,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList();
    partition(sudokuGenerator.newSudoku,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach(
      (entry) {
        List<int> tempListCompletes =
            completes[entry.key].expand((element) => element).toList();
        List<int> tempList = entry.value.expand((element) => element).toList();

        tempList.asMap().entries.forEach((entryIn) {
          int index =
              entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() +
                  (entryIn.key % 9).toInt() ~/ 3;

          if (boxInners.where((element) => element.index == index).length ==
              0) {
            boxInners.add(BoxInner(index, []));
          }

          BoxInner boxInner =
              boxInners.where((element) => element.index == index).first;

          boxInner.blokChars.add(BlokChar(
            entryIn.value == 0 ? "" : entryIn.value.toString(),
            index: boxInner.blokChars.length,
            isDefault: entryIn.value != 0,
            isCorrect: entryIn.value != 0,
            correctText: tempListCompletes[entryIn.key].toString(),
          ));
        });
      },
    );

    // complte generate puzzle sudoku
  }

  setFocus(int index, int indexChar) {
    tapBoxIndex = "$index-$indexChar";
    focusClass.setData(index, indexChar);
    showFocusCenterLine();
    setState(() {});
  }

  void showFocusCenterLine() {
    // set focus color for line vertical & horizontal
    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    this.boxInners.forEach((element) => element.clearFocus());

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach(
        (e) => e.setFocus(focusClass.indexChar!, Direction.Horizontal));

    boxInners
        .where((element) => element.index % 3 == colNoBox)
        .forEach((e) => e.setFocus(focusClass.indexChar!, Direction.Vertical));
  }

  setInput(int? number) {
    // set input data based grid
    // or clear out data
    if (focusClass.indexBox == null) return;
    if (boxInners[focusClass.indexBox!].blokChars[focusClass.indexChar!].text ==
            number.toString() ||
        number == null) {
      boxInners.forEach((element) {
        element.clearFocus();
        element.clearExist();
      });
      boxInners[focusClass.indexBox!]
          .blokChars[focusClass.indexChar!]
          .setEmpty();
      tapBoxIndex = null;
      isFinish = false;
      showSameInputOnSameLine();
    } else {
      boxInners[focusClass.indexBox!]
          .blokChars[focusClass.indexChar!]
          .setText("$number");

      showSameInputOnSameLine();

      checkFinish();
    }

    setState(() {});
  }

  void showSameInputOnSameLine() {
    // show duplicate number on same line vertical & horizontal so player know he or she put a wrong value on somewhere

    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    String textInput =
        boxInners[focusClass.indexBox!].blokChars[focusClass.indexChar!].text!;

    boxInners.forEach((element) => element.clearExist());

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Horizontal));

    boxInners.where((element) => element.index % 3 == colNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Vertical));

    List<BlokChar> exists = boxInners
        .map((element) => element.blokChars)
        .expand((element) => element)
        .where((element) => element.isExist)
        .toList();

    if (exists.length == 1) exists[0].isExist = false;
  }

  void checkFinish() {
    int totalUnfinish = boxInners
        .map((e) => e.blokChars)
        .expand((element) => element)
        .where((element) => !element.isCorrect)
        .length;

    isFinish = totalUnfinish == 0;
  }
}
