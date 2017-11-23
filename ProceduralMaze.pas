 program Proceduralmaze;
  uses crt;
    {

    TODO: list
    [x] Make a Pathfind algo
    [x] Implement Pathfind to GenerateMap
    [x] Make a Functional PlayerControl
    [x] LadingBar
    [x] Improve GenerateMap
    [x] Make stencil render
    [x] Make a menu and UI
    [x] Make Scoring System
    [] Make Highscore Database using file handling
    [] Bug Fixing

    }
    {===============================type declaration===============================}
  type
      COORD = record
      x : integer;
      y : integer;
    end;
  type
    ScoreData = record
      Nama :  string;
      score : real;
    end;

    type int2DArr = array[0..100,0..100] of integer;
    type COORDarr = array[1..10000]     of COORD;
    type arrScore = array[1..11]       of ScoreData;
    {==============================================================================}

  var

    player  : COORD;
    n,i,sel : integer;
    density : integer;
    map     : int2DArr;

    isGameOver,stopGame,isExit,Gamestart : boolean;
    inp                                  : char;
    Level,time                           : integer;
    GameMode                             : integer;
    score                                : real;

    stencilRender : boolean;
    viewRadius    : integer;

    SurvivalScores : arrScore;
    ArcadeScores  : arrScore;
    nama_temp : string;

    procedure SwapScore(var A : ScoreData; var B : ScoreData);
      var
        tmp : ScoreData;
      begin
        tmp := A;
        A := B;
        B := tmp;
      end;

    procedure sortScore(var scrs : arrScore);
      var i , j : integer;
             mi : integer;
      begin
              for i := 1 to 10 do
                begin
                mi := i;
                for j := i + 1 to 11 do
                  begin
                  if(scrs[j].score > scrs[mi].score) then
                    begin
                      mi := j;
                    end;
                  end;
                SwapScore(scrs[i],scrs[mi]);
              end;
      end;

    function newScoreData(nama : string; scr : real): ScoreData;
      var tmp : ScoreData;
      begin
        tmp.Nama := nama;
        tmp.score := scr;
        newScoreData := tmp;
      end;

    procedure insertScore(scr : ScoreData;mode : integer);
      begin

        case mode of
        1: begin
          ArcadeScores[11] := scr;
          sortScore(ArcadeScores);
        end;
        2:begin
          SurvivalScores[11] := scr;
          sortScore(SurvivalScores);
        end;
        end;
      end;


    procedure ShowScore();
      var i : integer;
      begin
        clrscr;
        writeln('Arcade Score : ');
        for i := 1 to 10 do
          begin
            writeln(i,'. ',ArcadeScores[i].nama,' ',ArcadeScores[i].score:0:2);
          end;
          writeln;
          writeln;
        writeln('Survival Score : ');
        for i := 1 to 10 do
          begin
            writeln(i,'. ',SurvivalScores[i].nama,' ',SurvivalScores[i].score:0:2);
          end;
        writeln('Press Enter to go back to menu');readln;
      end;

    procedure  LoadScoreData();
      begin
        //TODO: Load Scores from file
      end;

    procedure LoadConfig();
      begin
        // TODO: Load config and option from file handling
      end;

    procedure  SaveScoreData();
      begin
        //TODO: Load Scores from file
      end;

    procedure SaveConfig();
      begin
        // TODO: Load config and option from file handling
      end;

    function newCOORD(x,y : integer): COORD;
      var temp : COORD;
      begin
          temp.x := x;
          temp.y := y;
          newCOORD := temp;
      end;

    function COORDAisB(A,B : COORD): boolean;
      begin
        COORDAisB := (A.x = B.x) and (A.y = B.y);
      end;

    function COORDAaddB(A,B : COORD): COORD;
      var temp : COORD;
      begin
          temp.x := A.x + B.x;
          temp.y := A.y + B.y;
          COORDAaddB := temp;
      end;

    function pow(A,B : integer) : integer;
      var i,res : integer;
      begin
        res := 1;
        for i:=1 to B do
        begin
          res := res * A;
        end;
        pow := res;
      end;

    function Distance(A,B : COORD): integer;
      begin
        Distance := round(sqrt(pow((B.x - A.x),2) + pow((B.y-A.y),2)));
      end;

    function xisElementOf(x : integer;arr: array of integer; size : integer) : boolean;
      var res : boolean;
          i : integer;
      begin
        res := false;
        i := 1;
        repeat
          if(arr[i] = x)then
            res := true;
          i := i + 1;
        until (res or (i > size));
        xisElementOf := res;
      end;

    procedure ShowCOORD(A:COORD);
      begin
        write(A.x,',',A.y);
      end; // for debugging purpose

    function xyisElementOf(xy : COORD; arr: COORDarr;  size : integer) : boolean;
      var res : boolean;
          i : integer;
      begin
        res := false;
        for i := 1 to size do
          begin
          if(COORDAisB(xy,arr[i]))then
            res := true;
          end;
        xyisElementOf := res;
      end;

    procedure SwapCOORD(var A:COORD; var B:COORD);
      var tmp : COORD;
      begin
        tmp := A;
        A := B;
        B := tmp;
      end;

    procedure PushBackCOORD(Node : COORD;var Nodes:COORDarr;var size : integer);
      begin
        Nodes[size+1] := Node;
        size := size + 1;
      end;

    procedure PopOutCOORD(var Nodes:COORDarr;var size : integer);
      var i : integer;
      begin
        for i := 1 to size do
          SwapCOORD(Nodes[i],Nodes[i+1]);
        Nodes[size] := newCOORD(0,0);
        size := size - 1;
      end;

    function FloodFillAlgorithm(Node:COORD;map : int2DArr;MapSize : integer):integer;
      var
        res: integer;
        Q : COORDarr;
        Checked : COORDarr;
        sizeofQ,SizeofC: integer;
        North,East,South,West : COORD;
      begin
        res := 0;
        sizeofQ := 0;
        SizeofC := 0;
        if(map[Node.x,Node.y] = 0)then
          res := 1;
        PushBackCOORD(Node,Checked,SizeofC);
        PushBackCOORD(Node,Q,sizeofQ);
        while(sizeofQ > 0) do
          begin

            North := newCOORD(Q[1].x - 1 ,Q[1].y);
            East  := newCOORD(Q[1].x ,Q[1].y + 1);
            South := newCOORD(Q[1].x + 1 ,Q[1].y);
            West  := newCOORD(Q[1].x, Q[1].y - 1);
            if (map[North.x,North.y] = 0) and (North.x > 0) and not xyisElementOf(North,Checked,SizeofC) then
              begin
                res := res + 1;
                PushBackCOORD(North,Q,sizeofQ);
              end;
            if (map[East.x,East.y] = 0) and (East.y <= MapSize) and not xyisElementOf(East,Checked,SizeofC) then
              begin
                res := res + 1;
                PushBackCOORD(East,Q,sizeofQ);
              end;
            if (map[South.x,South.y] = 0) and (South.x <= MapSize) and not xyisElementOf(South,Checked,SizeofC) then
              begin
                res := res + 1;
                PushBackCOORD(South,Q,sizeofQ);
              end;
            if (map[West.x,West.y] = 0) and (West.y > 0) and not xyisElementOf(West,Checked,SizeofC) then
              begin
                res := res + 1;
                PushBackCOORD(West,Q,sizeofQ);
              end;
            PushBackCOORD(North,Checked,SizeofC);
            PushBackCOORD(East,Checked,SizeofC);
            PushBackCOORD(South,Checked,SizeofC);
            PushBackCOORD(West,Checked,SizeofC);
            PopOutCOORD(Q,sizeofQ);
          end;
          FloodFillAlgorithm := res;
      end;

    procedure RenderLoading(current : integer;max : integer; message : string);
      var percentage : integer;
      begin
        clrscr;
        for i := 1 to 20 do
          begin
            if(i <= ((current * 20) div max))then
              begin
                textbackground(green);
              end
            else
              begin
                textbackground(black);
              end;
            write('  ');
          end;
        textbackground(black);
        percentage := ((current * 100) div max);
        write('Loading : ',message);
        for i := 0 to percentage mod 3 do
          write('.');
        writeln(percentage,'%');
        if percentage = 100 then
          begin
            write('Press any key to continue');
            readkey;
          end;
      end;

    function GenerateMap(MapSize : integer ; _Density : integer ; var PlayerCOORD : COORD):int2DArr;
      var
        Obstacle: COORDarr;
        i,j : integer;
        tmp,startPoint,FinishPoint : COORD;
        MapOutput : int2DArr;
      begin
        _Density := ((_Density * (MapSize*MapSize)) div 100) - 2;

        for i := 1 to _Density do
          Obstacle[i] := newCOORD(0,0);


        startPoint := newCOORD(1,random(MapSize) + 1);
        FinishPoint := newCOORD(MapSize,random(MapSize) + 1);

        for i := 1 to MapSize do
        begin
          for j := 1 to MapSize do
              MapOutput[i,j] := 0;
        end;

        for i := 0 to MapSize + 1 do
        begin
          for j := 0 to MapSize + 1 do
            if (i = 0) or (j = 0) or (i = MapSize + 1) or (j = MapSize + 1) then
                MapOutput[i,j] := 1;
        end;

        writeln((MapSize*MapSize) - _Density);

        Obstacle[1] := newCOORD(random(MapSize)+1,random(MapSize)+1);
        for i := 2 to _Density do
          begin
              repeat
                  tmp := newCOORD(random(MapSize)+1,random(MapSize)+1);
              until not (xyisElementOf(tmp,Obstacle,i-1)
              or COORDAisB(startPoint,tmp)
              or COORDAisB(FinishPoint,tmp));
            Obstacle[i] := tmp;
          end;

          i := 1;
          j := 1;
          while( j  <= _Density ) do
          begin
            MapOutput[Obstacle[j].x,Obstacle[j].y] := 1;
            if(FloodFillAlgorithm(FinishPoint,MapOutput,MapSize) < ((MapSize*MapSize) - i)) then
              begin
                MapOutput[Obstacle[j].x,Obstacle[j].y] := 0;
                i := i - 1;
              end;
              j := j + 1;
              i := i + 1;
              RenderLoading(j,_Density,'Generating Map');
          end;
          MapOutput[FinishPoint.x,FinishPoint.y] := 3;
          MapOutput[startPoint.x,startPoint.y] := 2;
          GenerateMap := MapOutput;
          PlayerCOORD := startPoint;
      end;

    procedure PlayerControl(var player : COORD;var mapData : int2DArr;mapsize : integer);
      var k : char;
          Dir,tmp : COORD;
      begin
        tmp := newCOORD(0,0);
        Dir := newCOORD( 0, 0);
        if(keypressed) then
          k := readkey;
        case k of
        'W' : Dir := newCOORD(-1, 0);
        'w' : Dir := newCOORD(-1, 0);
        'A' : Dir := newCOORD( 0,-1);
        'a' : Dir := newCOORD( 0,-1);
        'S' : Dir := newCOORD( 1, 0);
        's' : Dir := newCOORD( 1, 0);
        'D' : Dir := newCOORD( 0, 1);
        'd' : Dir := newCOORD( 0, 1);
        'Q' : begin
          isGameOver := true;
          stopGame := true;
          end;
        'q' : begin
          isGameOver := true;
          stopGame := true;
          end;
        end;

        tmp := COORDAaddB(player,Dir);

        if(mapData[tmp.x,tmp.y] <> 1 ) then
          begin
            if (mapData[tmp.x,tmp.y] = 3) then
              isGameOver := true;
            mapData[player.x,player.y] := 0;
            mapData[tmp.x,tmp.y] := 2;
            player := tmp;
          end;
        delay(50);
      end;

    procedure Render(PlayerCOORD : COORD;RenderMap : int2DArr;size : integer);
      var
        i,j : integer;
        ref : array[0..3] of string = ('  ','##','2 ','##');
      {
        0 = nothin
        1 = wall/Obstacle (##) white
        2 = player (2) white
      }
      begin
        clrscr;
        for i := 0 to size + 1 do
        begin
          for j := 0 to size + 1 do
            begin
              if(stencilRender) then
                begin
                  if(Distance(PlayerCOORD,newCOORD(i,j)) < viewRadius) then
                    begin
                      if RenderMap[i,j] > 1 then
                        textcolor(blue)
                      else
                        textcolor(white);
                      write(ref[RenderMap[i,j]]);
                    end
                  else
                    write('  ');
                end
              else
              begin
                if RenderMap[i,j] > 1 then
                  textcolor(blue)
                else
                  textcolor(white);
                write(ref[RenderMap[i,j]]);
              end;

            end;
          writeln;
        end;
      end;

    procedure RenderMenu(selection : integer);
      begin
        clrscr;

        writeln('=====Game Mode======');

        if(selection = 0) then
          write('>')
        else
          write(' ');
        writeln('Start Arcade Mode');

        if(selection = 1) then
          write('>')
        else
          write(' ');
        writeln('Survival Mode');

        writeln('=======Setting======');

        if(selection = 2) then
          write('   >')
        else
          write('    ');
        write('Hard Mode : ');
        if(stencilRender) then
          writeln('[x]')
        else
          writeln('[ ]');

        if(selection = 3) then
          write('   >')
        else
          write('    ');
        writeln('View Radius :');
        write('<');
        for i := 3 to 10 do
          if i <= viewRadius then
            write('==')
          else
            write('  ');
        writeln('>',viewRadius,'px');

        writeln('=====================');
        writeln;

        if(selection = 4) then
          write('>')
        else
          write(' ');
        writeln('Exit');

        if(selection = 5) then
          write('>')
        else
          write(' ');
        writeln('Highscore');

      end;

      {<<======================== MAIN PROGRAM START HERE =========================>>}

  begin
    Randomize;

    stencilRender  := true;
    isExit := false;
    sel := 0;
    viewRadius := 5;
    repeat
    {======================== MAIN MENU ====================}
      repeat

        Level := 0;
        n := 15;

        stopGame := false;
        Gamestart := false;
        RenderMenu(sel);
        inp := readkey;
        case inp of
        'w' : sel := ((sel - 1) + 6) mod 6;
        'W' : sel := ((sel - 1) + 6) mod 6;
        's' : sel := (sel + 1) mod 6;
        'S' : sel := (sel + 1) mod 6;
        #13 : case sel of
          0 : begin
            Gamestart := true;
            GameMode  := 1;
          end;
          1 : begin
            Gamestart := true;
            GameMode  := 2;
            end;
          2 : stencilRender := not (stencilRender);
          4 : begin
            isExit := true;
            end;
          5 : begin
            ShowScore;
            end;
          end;
        'a' : case sel of
          3 : if viewRadius > 3 then
              viewRadius := viewRadius - 1;
        end;
        'A' : case sel of
          3 : if viewRadius > 3 then
              viewRadius := viewRadius - 1;
        end;
        'd' : case sel of
          3 : if viewRadius < 10 then
              viewRadius := viewRadius + 1;
        end;
        'D' : case sel of
          3 : if viewRadius < 10 then
              viewRadius := viewRadius + 1;
        end;
        'x' : exit;
        end;
      until (Gamestart or isExit);

  {=======================Gameplay============================}
      sel := 0;
      if Gamestart and not isExit then
        begin
          time := 0;
          score := 0;
          repeat
            stopGame := ((level = 50) and (GameMode = 1)) or ((GameMode = 2) and isGameOver);

            if GameMode = 2 then
              time := 1000;

            level := level + 1;
            isGameOver := false;

            if(n < 45) then
              n := n + 1;

            density := random(51) + 50;
            map := GenerateMap(n,density,player);

            while not(isGameOver) do
              begin
                Render(player,map,n);
                case GameMode of
                1:begin
                    time := time + 1;
                    score := ((level * 1000)/(time / 2));
                    writeln('              level-',level);
                    writeln('              Time Used : ',time);
                  end;
                2:begin
                    score := (level-1) * 1000;
                    time := time - 1;
                    writeln('              level-',level);
                    writeln('              Time Remaining : ',time);
                    isGameOver := (time = 0);
                    stopGame := isGameOver;
                  end;
                end;
                PlayerControl(player,map,n);
              end;
          until (stopGame);
          if(stencilRender)then
            score := score * 1.5 * (3/viewRadius);

          case GameMode of
          1:begin
            if(score > ArcadeScores[10].score) then
              begin
                clrscr;
                writeln(GameMode);
                writeln('NEW Highscore ',score:0:2);
                write('masukan nama anda : ');readln(nama_temp);
                insertScore(newScoreData(nama_temp,score),GameMode);
              end;
              ShowScore;
            end;
          2:begin
            if(level > SurvivalScores[10].score) then
              begin
                writeln('NEW Highscore ',score:0:2);
                write('masukan nama anda : ');readln(nama_temp);
                insertScore(newScoreData(nama_temp,score),GameMode);
              end;
              ShowScore;
            end;
          end;

        score := 0;
        end;

  {==============================================================}


    until (isExit);
    clrscr;
  end.
