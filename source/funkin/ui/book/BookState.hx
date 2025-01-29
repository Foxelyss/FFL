package funkin.ui.book;

import funkin.graphics.FunkinSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.ui.debug.DebugMenuSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.typeLimit.NextState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import funkin.data.song.SongData.SongMusicData;
import flixel.tweens.FlxEase;
import funkin.graphics.FunkinCamera;
import funkin.audio.FunkinSound;
import flixel.tweens.FlxTween;
import funkin.ui.MusicBeatState;
import flixel.util.FlxTimer;
import funkin.ui.AtlasMenuList;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.MenuList;
import funkin.ui.title.TitleState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.Prompt;
import funkin.util.WindowUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import funkin.ui.freeplay.backcards.*;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ShakeTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.data.song.SongRegistry;
import funkin.data.story.level.LevelRegistry;
import funkin.effects.IntervalShake;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.graphics.shaders.AngleMask;
import funkin.graphics.shaders.GaussianBlurShader;
import funkin.graphics.shaders.HSVShader;
import funkin.graphics.shaders.PureColor;
import funkin.graphics.shaders.BlueFade;
import funkin.graphics.shaders.StrokeShader;
import openfl.filters.ShaderFilter;
import funkin.input.Controls;
import funkin.play.PlayStatePlaylist;
import funkin.play.scoring.Scoring;
import funkin.play.scoring.Scoring.ScoringRank;
import funkin.play.song.Song;
import funkin.save.Save;
import funkin.save.Save.SaveScoreData;
import funkin.ui.AtlasText;
import funkin.ui.freeplay.charselect.PlayableCharacter;
import funkin.ui.freeplay.SongMenuItem.FreeplayRank;
import funkin.ui.mainmenu.MainMenuState;
import funkin.ui.MusicBeatSubState;
import funkin.ui.story.Level;
import funkin.ui.transition.LoadingState;
import funkin.ui.transition.StickerSubState;
import funkin.util.MathUtil;
import funkin.util.SortUtil;
import openfl.display.BlendMode;
import funkin.data.freeplay.style.FreeplayStyleRegistry;
import funkin.data.song.SongData.SongMusicData;
import funkin.input.Cursor;
#if FEATURE_DISCORD_RPC
import funkin.api.discord.DiscordClient;
#end
#if newgrounds
import funkin.ui.NgPrompt;
import io.newgrounds.NG;
#end

class BookState extends MusicBeatState
{
  // Поля для хранения данных о персонажах
  var characters = [
    {name: "Librarian", description: "Описание персонажа А", buttonLabel: "Играть за А"},
    {name: "Gunslinger", description: "Описание персонажа B", buttonLabel: "Играть за B"},
    {name: "Halfway kek", description: "Описание персонажа C", buttonLabel: "Играть за C"}
  ];

  // Кнопки выбора персонажей
  var characterButtons:Array<FlxButton>;

  // Элементы для отображения информации о выбранном персонаже
  var selectedCharacterName:FlxText;
  var selectedCharacterDescription:FlxText;
  var playButton:FlxButton;

  var screenSize = (1280, 720);

  override public function create():Void
  {
    super.create();
    #if FEATURE_DISCORD_RPC
    DiscordClient.instance.setPresence({state: "In the Menus", details: null});
    #end

    FlxG.cameras.reset(new FunkinCamera('mainMenu'));

    transIn = FlxTransitionableState.defaultTransIn;
    transOut = FlxTransitionableState.defaultTransOut;

    // We want the state to always be able to begin with being able to accept inputs and show the anims of the menu items.
    persistentUpdate = true;
    persistentDraw = true;

    var bg:FlxSprite = new FlxSprite(Paths.image('menuBG'));
    bg.scrollFactor.x = 0;
    bg.scrollFactor.y = 0.17;
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);
    trace("123123");
    // Создаем кнопки выбора персонажей
    var buttonHeights = screenSize[0];
    characterButtons = [];
    for (i in 0...characters.length)
    {
      var characterButton = new FlxButton(100, 10 + i * 50, characters[i].name, function() onCharacterSelected(i));
      characterButton.label.font = "Arial";
      add(characterButton);
      characterButtons.push(characterButton);
    }

    // Отображаем информацию о первом персонаже по умолчанию
    updateCharacterInfo(0);
    Cursor.show();
  }

  /**
   * Обработчик события нажатия на кнопку выбора персонажа
   */
  private function onCharacterSelected(index:Int):Void
  {
    if (index != -1)
    {
      updateCharacterInfo(index);
      trace(index);
    }
  }

  /**
   * Обновление информации о выбранном персонаже
   */
  private function updateCharacterInfo(index:Int):Void
  {
    var characterData = characters[index];

    // Обновляем имя персонажа
    if (selectedCharacterName == null)
    {
      selectedCharacterName = new FlxText(300, 20, 200, characterData.name, 62);
      selectedCharacterName.font = "Arial";
      add(selectedCharacterName);
    }
    else
    {
      selectedCharacterName.text = characterData.name;
    }
    trace(characterData.description);
    // Обновляем описание персонажа
    if (selectedCharacterDescription == null)
    {
      selectedCharacterDescription = new FlxText(300, 60, 200, characterData.description, 42);
      selectedCharacterDescription.font = "Arial";
      add(selectedCharacterDescription);
    }
    else
    {
      selectedCharacterDescription.text = characterData.description;
    }

    // Обновляем кнопку "Играть"
    if (playButton == null)
    {
      playButton = new FlxButton(300, 120, characterData.buttonLabel, onPlayClicked);
      playButton.label.font = "Arial";
      add(playButton);
    }
    else
    {
      playButton.label.text = characterData.buttonLabel;
    }
  }

  var busy:Bool;

  /**
   * Обработчик события нажатия на кнопку "Играть"
   */
  private function onPlayClicked():Void
  {
    // Здесь можно добавить логику перехода к игре с выбранным персонажем
    trace("Играем за персонажа: " + selectedCharacterName.text);

    busy = true;
    // letterSort.inputEnabled = false;
    var currentDifficulty:String = Constants.DEFAULT_DIFFICULTY;
    var currentVariation:String = Constants.DEFAULT_VARIATION;
    var targetInstId:String = null;
    var cap =
      {
        freeplayData: {levelId: null}
      };

    PlayStatePlaylist.isStoryMode = false;

    var targetSongId:String = 'unknown'; // cap?.freeplayData?.data.id ?? 'unknown';
    var targetSongNullable:Null<Song> = SongRegistry.instance.fetchEntry(targetSongId);
    if (targetSongNullable == null)
    {
      FlxG.log.warn('WARN: could not find song with id (${targetSongId})');
      return;
    }
    var targetSong:Song = targetSongNullable;
    var targetVariation:Null<String> = currentVariation;
    var targetLevelId:Null<String> = cap?.freeplayData?.levelId;
    PlayStatePlaylist.campaignId = targetLevelId ?? null;

    var targetDifficulty:Null<SongDifficulty> = targetSong.getDifficulty(currentDifficulty, currentVariation);
    if (targetDifficulty == null)
    {
      FlxG.log.warn('WARN: could not find difficulty with id (${currentDifficulty})');
      return;
    }

    if (targetInstId == null)
    {
      var baseInstrumentalId:String = targetSong?.getBaseInstrumentalId(currentDifficulty, targetDifficulty.variation ?? Constants.DEFAULT_VARIATION) ?? '';
      targetInstId = baseInstrumentalId;
    }

    // Visual and audio effects.
    FunkinSound.playOnce(Paths.sound('confirmMenu'));
    // if (dj != null) dj.confirm();

    // grpCapsules.members[curSelected].forcePosition();
    // grpCapsules.members[curSelected].confirm();

    // backingCard?.confirm();

    new FlxTimer().start(1, function(tmr:FlxTimer) {
      FunkinSound.emptyPartialQueue();

      Paths.setCurrentLevel(cap?.freeplayData?.levelId);
      LoadingState.loadPlayState(
        {
          targetSong: targetSong,
          targetDifficulty: currentDifficulty,
          targetVariation: currentVariation,
          targetInstrumental: targetInstId,
          practiceMode: false,
          minimalMode: false,

          #if FEATURE_DEBUG_FUNCTIONS
          botPlayMode: FlxG.keys.pressed.SHIFT,
          #else
          botPlayMode: false,
          #end
          // TODO: Make these an option! It's currently only accessible via chart editor.
          // startTimestamp: 0.0,
          // playbackRate: 0.5,
          // botPlayMode: true,
        }, true);
    });
  }
}
