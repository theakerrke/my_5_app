import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(BlockBlastGame());
}

class BlockBlastGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GameScreen());
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int gridSize = 10;
  List<List<int>> grid = [];
  int score = 0;
  int highScore = 0;
  List<List<List<int>>> availableBlocks = [];
  List<Color> blockColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _generateNewBlocks();
  }

  void _initializeGrid() {
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));
  }

  void _generateNewBlocks() {
    List<List<List<int>>> shapes = [
      [
        [1, 1, 1],
      ],
      [
        [1],
        [1],
        [1],
      ],
      [
        [1, 1],
        [1, 1],
      ],
      [
        [1, 1, 0],
        [0, 1, 1],
      ],
    ];
    availableBlocks = List.generate(
      3,
      (_) => shapes[random.nextInt(shapes.length)],
    );
  }

  bool _canPlaceBlock(int x, int y, List<List<int>> block) {
    for (int i = 0; i < block.length; i++) {
      for (int j = 0; j < block[i].length; j++) {
        if (block[i][j] == 1) {
          if (x + i >= gridSize ||
              y + j >= gridSize ||
              grid[x + i][y + j] == 1) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _placeBlock(int x, int y, List<List<int>> block) {
    if (!_canPlaceBlock(x, y, block)) return;
    setState(() {
      for (int i = 0; i < block.length; i++) {
        for (int j = 0; j < block[i].length; j++) {
          if (block[i][j] == 1) {
            grid[x + i][y + j] = 1;
          }
        }
      }
      _checkForCompletedLines();
      _generateNewBlocks();
    });
  }

  void _checkForCompletedLines() {
    List<int> fullRows = [];
    List<int> fullCols = [];

    for (int i = 0; i < gridSize; i++) {
      if (grid[i].every((cell) => cell == 1)) {
        fullRows.add(i);
      }
    }

    for (int j = 0; j < gridSize; j++) {
      if (grid.every((row) => row[j] == 1)) {
        fullCols.add(j);
      }
    }

    for (int row in fullRows) {
      grid[row] = List.generate(gridSize, (j) => 0);
      score += 10;
    }

    for (int col in fullCols) {
      for (int i = 0; i < gridSize; i++) {
        grid[i][col] = 0;
      }
      score += 10;
    }

    if (score > highScore) {
      highScore = score;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('Block Blast! Score: \$score'),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('🏆 \$highScore', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int x = index ~/ gridSize;
                int y = index % gridSize;
                return DragTarget<List<List<int>>>(
                  onWillAccept: (block) => _canPlaceBlock(x, y, block!),
                  onAccept: (block) => _placeBlock(x, y, block!),
                  builder:
                      (context, candidateData, rejectedData) => Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color:
                              grid[x][y] == 1
                                  ? Colors.yellow
                                  : Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                availableBlocks.map((block) {
                  return Draggable<List<List<int>>>(
                    data: block,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            block
                                .map(
                                  (row) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        row
                                            .map(
                                              (cell) =>
                                                  cell == 1
                                                      ? Container(
                                                        width: 20,
                                                        height: 20,
                                                        color: Colors.white,
                                                        margin: EdgeInsets.all(
                                                          2,
                                                        ),
                                                      )
                                                      : Container(
                                                        width: 20,
                                                        height: 20,
                                                        margin: EdgeInsets.all(
                                                          2,
                                                        ),
                                                      ),
                                            )
                                            .toList(),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          block
                              .map(
                                (row) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      row
                                          .map(
                                            (cell) =>
                                                cell == 1
                                                    ? Container(
                                                      width: 30,
                                                      height: 30,
                                                      color: Colors.white,
                                                      margin: EdgeInsets.all(2),
                                                    )
                                                    : Container(
                                                      width: 30,
                                                      height: 30,
                                                      margin: EdgeInsets.all(2),
                                                    ),
                                          )
                                          .toList(),
                                ),
                              )
                              .toList(),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
