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
import funkin.ui.book.BookState;
import funkin.ui.title.TitleState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.Prompt;
import funkin.util.WindowUtil;
import funkin.graphics.FunkinSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.ui.debug.DebugMenuSubState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
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
  var menuItems:MenuTypedList<AtlasMenuItem>;

  var magenta:FlxSprite;
  var camFollow:FlxObject;
  var characters = [
    {name: "Librarian", description: "Описание персонажа А", buttonLabel: "Играть за А"},
    {name: "Gunslinger", description: "Описание персонажа B", buttonLabel: "Играть за B"},
    {name: "Halfway kek", description: "Описание персонажа C", buttonLabel: "Играть за C"}
  ];

  // Кнопки выбора персонажей
  var characterButtons:Array<FlxUIButton>;

  // Элементы для отображения информации о выбранном персонаже
  var selectedCharacterName:FlxText;
  var selectedCharacterDescription:FlxText;
  var playButton:FlxButton;

  var screenSize = [1280, 720];
  var overrideMusic:Bool = false;

  static var rememberedSelectedIndex:Int = 0;

  public function new(?_overrideMusic:Bool = false)
  {
    super();
    overrideMusic = _overrideMusic;
  }

  override function create():Void
  {
    #if FEATURE_DISCORD_RPC
    DiscordClient.instance.setPresence({state: "In the Menus", details: null});
    #end

    FlxG.cameras.reset(new FunkinCamera('mainMenu'));

    transIn = FlxTransitionableState.defaultTransIn;
    transOut = FlxTransitionableState.defaultTransOut;

    if (!overrideMusic) playMenuMusic();

    // We want the state to always be able to begin with being able to accept inputs and show the anims of the menu items.
    persistentUpdate = true;
    persistentDraw = true;

    var bg:FlxSprite = new FlxSprite(Paths.image('book/title_screen'));
    bg.scrollFactor.x = 0;
    bg.scrollFactor.y = 0.17;
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    camFollow = new FlxObject(0, 0, 1, 1);
    add(camFollow);

    magenta = new FlxSprite(Paths.image('menuBGMagenta'));
    magenta.scrollFactor.x = bg.scrollFactor.x;
    magenta.scrollFactor.y = bg.scrollFactor.y;
    magenta.setGraphicSize(Std.int(bg.width));
    magenta.updateHitbox();
    magenta.x = bg.x;
    magenta.y = bg.y;
    magenta.visible = false;

    // TODO: Why doesn't this line compile I'm going fucking feral

    if (Preferences.flashingLights) add(magenta);

    menuItems = new MenuTypedList<AtlasMenuItem>();
    add(menuItems);
    menuItems.onChange.add(onMenuItemChange);
    menuItems.onAcceptPress.add(function(_) {
      FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
    });

    menuItems.enabled = true; // can move on intro

    // FlxG.camera.setScrollBounds(bg.x, bg.x + bg.width, bg.y, bg.y + bg.height * 1.2);

    super.create();

    // This has to come AFTER!
    this.leftWatermarkText.text = Constants.VERSION;
    // this.rightWatermarkText.text = "blablabla test";

    // NG.core.calls.event.logEvent('swag').send();
    var buttonHeights = screenSize[1] / 3;
    characterButtons = [];
    for (i in 0...characters.length)
    {
      var characterButton = new FlxUIButton(100, 10 + i * buttonHeights, characters[i].name, function() onCharacterSelected(i));
      characterButton.label.font = "Arial";
      characterButton.label.size = 46;
      // characterButton.height = buttonHeights;
      // characterButton.width = buttonHeights;
      // characterButton.label.fieldWidth *= 3;
      // characterButton.scale.x = characterButton.scale.y = 3;
      characterButton.updateHitbox();
      // characterButton.icon = new FlxSprite(Paths.image('menuBG'));
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
    var startX = screenSize[0] / 2;

    // Обновляем имя персонажа
    if (selectedCharacterName == null)
    {
      selectedCharacterName = new FlxText(startX, 20, startX - 10, characterData.name, 62);
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
      selectedCharacterDescription = new FlxText(startX, 60, startX - 10, characterData.description, 42);
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
      playButton = new FlxButton(startX, 120, characterData.buttonLabel, onPlayClicked);
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

    var targetSongId:String = 'bookfox'; // cap?.freeplayData?.data.id ?? 'unknown';
    var targetSongNullable:Null<Song> = SongRegistry.instance.fetchEntry(targetSongId);
    if (targetSongNullable == null)
    {
      trace('WARN: could not find song with id (${targetSongId})');
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

  function playMenuMusic():Void
  {
    FunkinSound.playMusic('freakyMenu',
      {
        overrideExisting: true,
        restartTrack: false,
        // Continue playing this music between states, until a different music track gets played.
        persist: true
      });
  }

  function resetCamStuff(?snap:Bool = true):Void
  {
    // FlxG.camera.follow(camFollow, null, 0.06);

    // if (snap) FlxG.camera.snapToTarget();
  }

  function createMenuItem(name:String, atlas:String, callback:Void->Void, fireInstantly:Bool = false):Void
  {
    var item = new AtlasMenuItem(name, Paths.getSparrowAtlas(atlas), callback);
    item.fireInstantly = fireInstantly;
    item.ID = menuItems.length;

    item.scrollFactor.set();

    // Set the offset of the item so the sprite is centered on the origin.
    item.centered = true;
    item.changeAnim('idle');

    menuItems.addItem(name, item);
  }

  override function closeSubState():Void
  {
    magenta.visible = false;

    super.closeSubState();
  }

  override function finishTransIn():Void
  {
    super.finishTransIn();

    // menuItems.enabled = true;

    // #if newgrounds
    // if (NGio.savedSessionFailed)
    // 	showSavedSessionFailed();
    // #end
  }

  function onMenuItemChange(selected:MenuListItem)
  {
    // camFollow.setPosition(selected.getGraphicMidpoint().x, selected.getGraphicMidpoint().y);
  }

  #if FEATURE_OPEN_URL
  function selectDonate()
  {
    WindowUtil.openURL(Constants.URL_ITCH);
  }

  function selectMerch()
  {
    WindowUtil.openURL(Constants.URL_MERCH);
  }
  #end

  #if newgrounds
  function selectLogin()
  {
    openNgPrompt(NgPrompt.showLogin());
  }

  function selectLogout()
  {
    openNgPrompt(NgPrompt.showLogout());
  }

  function showSavedSessionFailed()
  {
    openNgPrompt(NgPrompt.showSavedSessionFailed());
  }

  /**
   * Calls openPrompt and redraws the login/logout button
   * @param prompt
   * @param onClose
   */
  public function openNgPrompt(prompt:Prompt, ?onClose:Void->Void)
  {
    var onPromptClose = checkLoginStatus;
    if (onClose != null)
    {
      onPromptClose = function() {
        checkLoginStatus();
        onClose();
      }
    }

    openPrompt(prompt, onPromptClose);
  }

  function checkLoginStatus()
  {
    var prevLoggedIn = menuItems.has("logout");
    if (prevLoggedIn && !NGio.isLoggedIn) menuItems.resetItem("login", "logout", selectLogout);
    else if (!prevLoggedIn && NGio.isLoggedIn) menuItems.resetItem("logout", "login", selectLogin);
  }
  #end

  public function openPrompt(prompt:Prompt, onClose:Void->Void):Void
  {
    menuItems.enabled = false;
    persistentUpdate = false;

    prompt.closeCallback = function() {
      menuItems.enabled = true;
      if (onClose != null) onClose();
    }

    openSubState(prompt);
  }

  function startExitState(state:NextState):Void
  {
    menuItems.enabled = false; // disable for exit
    rememberedSelectedIndex = menuItems.selectedIndex;

    var duration = 0.4;
    menuItems.forEach(function(item) {
      if (menuItems.selectedIndex != item.ID)
      {
        FlxTween.tween(item, {alpha: 0}, duration, {ease: FlxEase.quadOut});
      }
      else
      {
        item.visible = false;
      }
    });

    new FlxTimer().start(duration, function(_) FlxG.switchState(state));
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.onMobile)
    {
      var touch:FlxTouch = FlxG.touches.getFirst();

      if (touch != null)
      {
        for (item in menuItems)
        {
          if (touch.overlaps(item))
          {
            if (menuItems.selectedIndex == item.ID && touch.justPressed) menuItems.accept();
            else
              menuItems.selectItem(item.ID);
          }
        }
      }
    }

    Conductor.instance.update();

    // Open the debug menu, defaults to ` / ~
    // This includes stuff like the Chart Editor, so it should be present on all builds.
    if (controls.DEBUG_MENU)
    {
      persistentUpdate = false;

      FlxG.state.openSubState(new DebugMenuSubState());
    }

    #if FEATURE_DEBUG_FUNCTIONS
    // Ctrl+Alt+Shift+P = Character Unlock screen
    // Ctrl+Alt+Shift+W = Meet requirements for Pico Unlock
    // Ctrl+Alt+Shift+M = Revoke requirements for Pico Unlock
    // Ctrl+Alt+Shift+R = Score/Rank conflict test
    // Ctrl+Alt+Shift+N = Mark all characters as not seen
    // Ctrl+Alt+Shift+E = Dump save data
    // Ctrl+Alt+Shift+L = Force crash and create a log dump

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.P)
    {
      FlxG.switchState(() -> new funkin.ui.charSelect.CharacterUnlockState('pico'));
    }

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.W)
    {
      FunkinSound.playOnce(Paths.sound('confirmMenu'));
      // Give the user a score of 1 point on Weekend 1 story mode (Easy difficulty).
      // This makes the level count as cleared and displays the songs in Freeplay.
      funkin.save.Save.instance.setLevelScore('weekend1', 'easy',
        {
          score: 1,
          tallies:
            {
              sick: 0,
              good: 0,
              bad: 0,
              shit: 0,
              missed: 0,
              combo: 0,
              maxCombo: 0,
              totalNotesHit: 0,
              totalNotes: 0,
            }
        });
    }

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.M)
    {
      FunkinSound.playOnce(Paths.sound('confirmMenu'));
      // Give the user a score of 0 points on Weekend 1 story mode (all difficulties).
      // This makes the level count as uncleared and no longer displays the songs in Freeplay.
      for (diff in ['easy', 'normal', 'hard'])
      {
        funkin.save.Save.instance.setLevelScore('weekend1', diff,
          {
            score: 0,
            tallies:
              {
                sick: 0,
                good: 0,
                bad: 0,
                shit: 0,
                missed: 0,
                combo: 0,
                maxCombo: 0,
                totalNotesHit: 0,
                totalNotes: 0,
              }
          });
      }
    }

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.R)
    {
      // Give the user a hypothetical overridden score,
      // and see if we can maintain that golden P rank.
      funkin.save.Save.instance.setSongScore('tutorial', 'easy',
        {
          score: 1234567,
          tallies:
            {
              sick: 0,
              good: 0,
              bad: 0,
              shit: 1,
              missed: 0,
              combo: 0,
              maxCombo: 0,
              totalNotesHit: 1,
              totalNotes: 10,
            }
        });
    }

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.N)
    {
      @:privateAccess
      {
        funkin.save.Save.instance.data.unlocks.charactersSeen = ["bf"];
        funkin.save.Save.instance.data.unlocks.oldChar = false;
      }
    }

    if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.E)
    {
      funkin.save.Save.instance.debug_dumpSave();
    }
    #end

    if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
    {
      FlxG.sound.music.volume += 0.5 * elapsed;
    }

    if (_exiting) menuItems.enabled = false;

    if (controls.BACK && menuItems.enabled && !menuItems.busy)
    {
      FlxG.switchState(() -> new TitleState());
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
    }
  }
}
