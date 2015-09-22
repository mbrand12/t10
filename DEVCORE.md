# "T" * 10 Development Diary
> a.k.a DEVCORE # because DEVDIARY just doesn't sound as cool.

I will use this text as a part of development process and as a markdown
exercise. Orginaly this was the readme before it became more of a development
diary.

This is a long document written mostly for myself, so that I may learn more and
laugh at it sometimes in the future as well. With that being said feel free to
read and suggest stuff.

Also expect typos and grammar errors, and other errors... expect errors.

## Table of Contents
<!-- using https://github.com/jonschlinkert/marked-toc -->

<!-- toc -->

* [Motivation](#motivation)
  * [Short History](#short-history)
* [Design](#design)
  * [Ideas](#ideas)
    * [Plot, story and narrative](#plot-story-and-narrative)
    * [Dungeon](#dungeon)
    * [Rooms](#rooms)
    * [Hero](#hero)
    * [Engine](#engine)
    * [Items](#items)
    * [Events](#events)
    * [Characters](#characters)
  * [Key Concepts](#key-concepts)
    * [Class and method hierarchy suggestion](#class-and-method-hierarchy-suggestion)
  * [Implementation details](#implementation-details)
    * [Misc ideas](#misc-ideas)
    * [Rooms and dungeon generation](#rooms-and-dungeon-generation)
    * [Verbs, nouns and modifiers](#verbs-nouns-and-modifiers)
* [Development](#development)
  * [Development details and motivations](#development-details-and-motivations)
    * [Folder structure](#folder-structure)
    * [Workflow](#workflow)
* [Conclusion](#conclusion)

<!-- toc stop -->

## Motivation

I jumped straight into Rails and since I had some experience working with
frameworks (codeigniter php) and some programming experience (java) I was able
to accept new concepts pretty fast. I didn't have problems understanding ruby
language concepts at its basic level as well, though closures took some time
and am not yet used to modules and mixins.

However, as I was working on sample_app from [railstutorial] by Michael Hartl, I
noticed that the ruby knowledge is not 'sticking' and that I constantly have the
feeling that I am missing some feature of ruby (and to some extent rails as
well) that I should know.

So after finishing with the app I decided to take a step back of sorts and
[LRTHW]. At first the exercises where dull and boring but I kept going trough
them and I feel like it really pays off to work this way at least until one
gets a solid foundation and maybe more importantly work habit.

In exercise 45 you are tasked to create your own text adventure game using the
exercise 43 as a guide, and although I find this tedious and boring to do, I
will still do it because I noticed the good effect previous exercises had on me.

Not to mention that I have noticed resistance to coding when I have a 'blank
paper' in front of me especially when I am faced with something I do on my own
rather than as a part of a task or an exam. While this has been showing up from
time to time it really became prominent in this project. I think that [Fear of
Programing] presentation by Nathaniel Talbott really puts this well and has a
bunch of good ideas and suggestions for overcoming it.

Besides exercise 45, I will focus on 46 and 47 since they introduce folder
structure and testing, as well as 48 and 49 in the future.

I will also try to do it with a top-down approach since I am not that good with
abstractions (I tend just to start coding little things and sort of combine
it), and will also try to do TDD/BDD since I am not used to that as well. Using
more of git is a welcome bonus and I will use bbatsov's [style guide].

### Short History

Finished faculty and as a final exam had to build an app using codeigniter
(codeginiter was a suggestion though and an awesome one at that). I liked the
concept of framework so I decided to focus more on that and to try to build some
sort of career with web development. At the same time I wanted to learn a new
programing language so that I could "broaden my horizons" and get more insight
into programming.

Ruby was there as a choice since it was different from java and c#. So, when I
found out about Ruby on Rails it proved as a excellent opportunity for me to
learn new things and maybe find my programming career path. So far I am liking
pretty much everything.

## Design

Will first start with a few __Ideas__, then distill them into __Key Concepts__
and then work out some __Implementation details__, ideas and specifics.

### Ideas

#### Plot, story and narrative

The hero wakes up in front of an entrance to a dungeon, nothing much is known
about the dungeon or the hero. Progressing trough the rooms of the dungeon
reveals bits and peaces of the plot. Only once Hero knows the whole story will
the door to the Final Room open.Narrative will be in 1st person present tense
for the most parts.

I will also try to craft the narrative in such way that there is no immersion
breaking. So hero won't suffer 1 damage or heal 1 damage but there will be a
description of his state. There will be no help commands etc. Same goes for
saving and loading. English is not my primary language but it will be a fun
challenge.

#### Dungeon

The dungeon contains nine rooms which randomly change every time a new game is
started and one final room. Each room has up to 4 doors that are connected to
other rooms. The dungeon will be randomly generated picking up rooms from the
pool following specific rules.

#### Rooms

Each room will have one entrance and at most three exits. Hero will need to
travel to each of the rooms to complete the tests and collect the pieces of the
plot in order to access the final room.

Upon each doorway there is an animal crest Dragon, Phoenix, Tiger and Tortoise.
When a hero looks upon a crest he will recall what room it leads to if he had
visited it. It could be also used as a way of navigation.

Following will be some very basic guidelines, so that I can have some direction
while developing the rooms.

##### EntranceRoom

Idea is to introduce the player with the commands via narration. The hero is in
front of a gate and everything is depressing. This leads the player to assume
that this will be a dark and gloomy story, but weather it will be is left to be
seen.

##### R11 - EmptyRoom

A seemingly empty room until the hero tries to leave.

##### R12 - SimpleRoom

The Hero finds the peace of the plot right away but the narration in the room
might hint that there is a greater secret in there, even though there wont be,
or maybe it will.

##### R13 - ArmorRoom

Hero gets trapped in the room by a big metal armor robot, hero needs to
activate and equip the armor to battle the robot in order to get the peace that
is powering it and to be able to get out. Narratively the Hero doesn't know
what a robot is.

##### R14 - BossRoom

Hero needs all but one plot peace and some other items to be able to battle
this boss. The hero will be able to engage the Boss but will lose if Hero
doesn't have a specific item (or maybe an armor from the Armor room) etc.

##### R21 - JungeRoom

The hero needs to help the soldiers to get to the helicopter. For some reason
the soldiers see Hero as their sergeant/commander and will follow their orders.
Getting them to the chopper dispels the room and the Hero is able to proceed.

##### R22 - TrapRoom

A hallway like room filled with traps that the Hero must overcome to get to the
other side, when the Hero returns from the room from the other side Hero must
overcome the traps again but this time in reverse, the award is the plot peace
and the free pass trough the hallway like room.

##### R23 - MazeRoom

A maze in which something hunts the Hero, if hero makes three mistakes the
something kills the hero.

##### R31 - HiddenDoorRoom

At first the room looks just like a room with a door on each side and a peace
that is relatively easy to find, then a much harder puzzle opens the hidden
third door.

##### R32 - MachineryRoom

Hero gets to operate a complex machinery which can lead the Hero to the puzzle
peace or any of the two doors. All the parts are evident, the room should focus
on the machinery.

##### R4 - HallRoom

A big room in which many characters appear which Hero can talk to, some appear
only when a puzzle is complete in some of the rooms. Some are there to provide
hints and details to the story.

##### EndRoom

A room that is the same as the entrance room but much more positive.

#### Hero

Hero will have have hit points or chances. Hit points can be depleted by
picking a wrong choice when presented with one. Damage will be normal, critical
or instant death.

Hero will also be able to recover/heal some hit points based upon some choices,
specific sequences or random events, like upon room exit.

#### Engine

Engine will be required to load the dungeon and start the game. It will also
support a save/load game option. At the start it will provide the option of
loading the game. Game can be saved only after hero exits the room. Upon game
over there will be a load game option. Every time Hero exits a room he will
have the chance to save.

#### Items

Hero will be able to pick up items in the room and place it in satchel, then
use them when some event occurs. Possible considerations for consumable items
as well?

#### Events

Each room can have one or more events. Some events will be random upon dungeon
generation, others will have a chance occurrence, some will be fixed based on
the room type etc.

#### Characters

Each room can have events where the Hero can meet a character that will either
help or challenge the Hero, they may be item rewards included.

### Key Concepts

Extracted from ideas.

Nouns:

- Hero
- Dungeon
- Rooms
- Plot
- Hit points
- Engine
- Item
- Satchel/Inventory
- Event
- Character

Verbs:

- Save/Load
- Recover/Damage
- Enter/Exit
- Add/Remove item

#### Class and method hierarchy suggestion

__Note:__ if it has a () it is a method otherwise attribute. Objects are
capitalized.

- Hero
  - hit_points
  - damage()
  - heal()
  - dead?()
- Room
  - enter()
  - exit()
  - FinalRoom
- Dungeon
  - generate()
- Engine
  - save()
  - load()
  - start()
- Item
  - Consumable
- Inventory
  - add_item()
  - remove_item()

### Implementation details

#### Misc ideas

#### Rooms and dungeon generation

My initial idea is to use Rooms and then subclass it for every new room. This
will help me in designing dungeon generator. Inheritance is mostly looked down
upon so I am considering using modules instead, will see.

I decided that every room should have up to 4 doors. The problem I have is how
to implement movement of the hero and orientation. Just writing go south is not
really intuitive since the player should then know where south is which can be
fixed with a compass but another idea I have is to use markings/crest on each
of the four doors.

Each crest corresponds to one of the sides so for example turtle crest is for
north etc. The idea is that the player if necessary uses pen and paper to
sketch the dungeon layout as exploring. The problem might arise when the rooms
kind overlap on the written map. I sort of fixed that by not specifying the
length of the hallways or the shape, it is kinda lacking but I don't think it
needs the added complexity.

The problem is that if a room has fixed exits the algorithm needed for
generation would be very complex (far far beyond my ability) so rather then
absolute internal orientation the idea is to have relative orientation to a
single door that will be marked as origin door (the door which lead to the room
that generated this room). What this basically means is that the inside of the
room will, for example always have a exit on the left from where the Hero
always stands, but on the outside that room will be rotated to fit the dungeon.

Now that the exits to the room can be rotated rather than being fixed the
problem of creating an algorithm boils down to insuring that there is no
occurrence where all the room exits will read to one-door room preventing the
hero to reach all the rooms.

Since the game contains 10 challenges I fixed the number of rooms to 10 in
total plus Entrance.

Since each room is limited by doors then I can categorize rooms based on the
number of doors it has and then tweak the number of each room category and fill
the rest with one-door rooms.

So after a bunch of drawings etc. a dungeon should have:

- 1 4-door room
- 2 3-door rooms
- 3 2-door rooms
- 5 1-door rooms

So now the algorithm boils down to:

- Generate Entrance room then randomly generate room that isn't one-door room.
- For each of the door of the current room generate another room.
- If a new room is a one-door room check if the current room will have one door
  left for a non-one-door room in order to prevent the possibility of a room
  having just one-door rooms and not being connected to next non-one-door room
  if there are any left.
- Add each room to a list of rooms in order to know which is the next room to
  move to.
- Insure that every room is properly connected to the other room.

There will probably be a bunch of other checks to insure that the dungeon is
properly built but this is the most important gist of it.

#### Verbs, nouns and modifiers

The basic idea is to use words as symbols sorted into verbs, nouns and modifiers
to trigger different stuff. For example verbs should activate methods of the
same name. To allow more freedom the basic idea is to allow synonyms for
words.

Nouns should mostly be points of interest (wall, pedestal etc.) and item names.

Modifiers should be used to modify how a certain noun should be used it will
also carry actual modifiers that other methods may set up.

All of the verbs, nouns and modifiers have their own synonyms to allow more
freedom while expressing the commands etc.

While games that are played via keyboard or controller have a more or less the
same input, each room has their own rules for input so most of the classes had
to be implemented following the verbs, nouns and modifiers idea.

#### Events

While from the design standpoint the idea of events was to create randomly
assigned events to each room, from the implementation standpoint it was to
separate logic based upon the choices the player can make during the text
input.

For example during the save game event the player can only chose yes and no,
meaning that it can't chose to for example look around the room etc. So rather
than using a bunch of flags and making an already bloated classes in even
bigger ones (I currently lack knowledge and ideas to make them slimmer and
better organized than this) I would simply make a new class and redirect the
player text input to that class.

The good thing about this is that it makes easier to implement NPC dialog for
example and much complex events such as the armor battle.

#### Armor Room Battle

Armor room features the fist major event which boils down to a turn based
battle. The challenge is/was to explain to the player what happens inside of
the robot (or the "giant armor") without using any terms that might be
considered sci-fi in the first person narration.

The other challenge was designing a battle system which works more like a
puzzle and to make figuring out how the armor works as a part of it by giving
no idea what commands the player can issue but putting enough hints so that it
doesn't become something that needs an outside source. The way I did this is by
providing a random attack option when the player just types random stuff on the
keyboard. The idea is to simulate the "panic" that Hero experiences etc.

The battle itself boils down to finding out which moves are effective against
what, which ones are useless and most useful but in very specific situations.
For example once the player finds a proper use of a kick attack the player can
basically keep the opponent in a loop and the battle practically becomes
trivial. The idea is not to make the player frustrated by drawing out the
battle too much, though additional balancing may be needed.

While the battle has mostly random attack pattern there are some things that
allow some prediction while still leaving enough chance for it to fail. For
example as with every attack the details about opponent attacks are given the
player should be able to see that the opponent never repeats an attack. Given
that the opponent has only 3 attacks with certain moves the player can score
critical damage.

While the stats of the armor can be checked the opponent stats are not
revealed. Both have 3 main stats (and the armor has one more). Those stats are
basically health, ability/movement points, mana/magic points. The armor has an
additional orange bar which is there mostly as a red herring that might come
into play much later in some other room.

The stats management becomes important because when the ap bar/vial empties the
player cannot perform some of the actions, same goes for the opponent as well.

One of my main goals was to try to sustain the narrative immersion as long as
possible hence there are little "traditional" damage reports and such. The only
place where it seemed ok to bring a little sci-fi flavor was with the robots
voice ai.

#### Simple room and satchel

Simple room is build as an easy (well or at least easier than the armor room )
way to get a shiny piece and combine it with the amulet. It is meant to test
the basic features of inventory management such as inspecting, using, placing
in the satchel and combining.

The room it self consists of looking and trying to use as the things hinted in
the descriptions or other things without making it too hard.


## Development

### Development details and motivations

#### Folder structure

Decided to use ruby app folder structure partly inspired by [LRTHW] exercise 46
and partly just by looking at GitHub's ruby repositories. At first,  I wanted to
make a gem out of it right away, but then I thought that I already have enough
on my plate and will opt to make it into a gem in the later stages, if at all
since I don't know if this should be a gem but I'll see.

#### Workflow

Here I will outline my current workflow and try to improve upon it as I get more
experience programming. After that I will go in-dept for each step and my
motivation for doing the step.

As with pretty much everything here this will change allot as I refine it and
learn about good practice etc.

Currently my workflow is:

1. devcore
2. test/prototyping
3. document
4. implement
5. style
6. change log
7. git

##### 1. Readme/Devlog

When I get an idea I usually note it in a [Idea](#idea) section of the DEVCORE.
Depending on how good and/or important idea it is, I will go trough the other
steps. Though, more often than not the idea will be a implementation idea rather
than conceptual, so I note it down in the [Implementation ideas
](#implementation-details), this usually happens when I write documentation,
sometimes even after the fact as a reflection and clarification.

In the mean time I also started using Vim. I did this in effort to get used to
the command line more in general and to find a way to increase my productivity
in the long run, I have no idea if it will work out in that regard. During that
I also finished the [ruby koans] using Vim and [rubymonk] exercises and got to
know ruby API better, it was more effective then I though.

##### 2. Test/Prototyping

When I get a plan I try to go and test it out. It totally goes against the way
I have been used to program but even at this beginning point I can see the
benefits since it directs focus on faster implementation for the things I need
right now rather than just making a bunch of stuff haphazardly, though old
habits die hard.

However, I also tend to use prototyping where I implement just part of feature
with no regards to other things in a form of a throwaway. This helps me get a
bigger picture while not worrying about other things.

Currently I am using minitest since I simply prefer it over RSpec and at this
point it would be just another language that I must learn. And at this point in
my learning process I just don't really 'get' why is RSpec a more popular
choice. I mean, it does look more verbose maybe but it also looks less defined
and less precise. But this is a beginners point of view I am sure that as I get
more experience I would be able to understand why should I learn to RSpec too.

My current opinion is that is really suck at testing and that I need to improve
it. The problem is that for most parts I find it very hard to test specific
classes and most of my test boil down to integration tests (even though the are
still in the unit folder...) and in general it is very hard to get used to even
when I can see the obvious good sides. Other is that I am mostly lazy and lack
the habit of doing it, which I will try to overcome and create good habits.

##### 3. Implement

Finaly, code! This is the fun part and the part that made me like programming;
figuring out the best way (or some way at first) to make something work.

I try to follow the [red-green-refactor] as well the first code is rather
simple. Since writing code for me is usually a process of constant tweaking,
this suits me well.

The problem is that I usually think trough code, and tests don't fully fit
that. Actually they do, since I usually write some code then run the code using
some simple running code, so turning that running code into a test is a good
idea. The problem is that the test sound too official to me and that tends to
put me out of creative process. Though, I believe that if I write more tests I
will get used to them and not view them is such constricting manner, especially
since I can see the benefits.

I remember much earlier in my programming history how I would stress out when
the code that I wrote didn't work on the first run. Now when that happens I
become even more suspicious. The stress actually comes from not understanding
the language good enough and not cutting methods into smaller parts.

I will run `$ rubocop` from time to time to see the suggestions and will check
the [style guide] or some repository which coding style I like and try to
follow the guidelines. Tough I don't adhere to it totally, but try my best to
be consistent, and it provided me with some good suggestions or directions more
than once.

##### 4. Document

I tried to document as soon as I would write some method/etc but I noticed that
while this helps me in regards that it can show potential implementation
problems it also pushes me into 'thinking' mode rather than in the 'working'
mode.

This effectively stops me and makes me think far too many steps ahead, and
as with always a proper balance of thinking ahead and making code work now must
me maintained in order for one to be productive. As with tests I believe that
as I write more documentation, it will affect me less negatively.

So, in that light, I decided to push the documentation much lower down the
workflow and near the end of the feature branch when I have something solid
that works, and if I get some ideas or problems explaining I will either fix it
right away or will put it into a TODO.

Also code, especially in the beginning, constantly changes as better design
ideas and options show themselves trough work, having to edit the documentation
as well brakes the pace for me.

YARD really helps in a way that it provides an immediate feedback with the `$
yard server` command so that rather than spending to much time thinking about
documentation abstractly I just can tinker with the look and feel and check the
official tag documentation on a per need basis. I understand that this is
nothing new and that people have been doing it this way for quite some time but
it is new for me.

Documentation definitely helps me design better because when I can't explain
the point of the method or what it does, chances are I made a mistake in my
design somewhere, or maybe I am just bad at explaining things.

Being somewhat close to the end of the documentation of at least some parts of
the code I can say that documenting is much harder than I though it will be.
It is very hard to know when to stop adding "useful" info is one of those hard
things as well as which methods and classes to document. The other is that one
can clearly see the very bad design ideas while trying to explain it to the
"viewer".

The thing that I dislike rather than just find troublesome is that the comments
really bloat the classes (which are already huge). I think that I will be able
to see the true value of this when somebody else reads the documentation or
enough time passes that I forget most of the stuff about this project and read
it again.

##### 5. Change log

Change logs where always problematic for me. Actually both change logs and
keeping with different versions and backups in case something broke. For the
second one, git and GitHub made it much much easier (and somewhat more
complicated at the same time, more about that later).

For the change log, olivierlacan's [keep-a-changelog] is a really helpful
guide, that also had acquainted me with git tags and made many other things
make more sense. Thought, learning what to put in a change log is as
problematic as what to document and how much to document.

##### 6. Git

As in tone with pretty much everything in this devdiary, git is a completely
new thing for me. As soon as I started using it I wondered why I didn't use it
before. But as with everything here it is complex on many levels.

Which made me restart the project more than a few times since I did not want to
deal with the mess I made, at least not until I got up to a first major
(working) version of this project. I follow [Semantic Versioning] and decided
that I will push onto a public repository (GitHub) only when I reach a fist
major version.

[LearnGitBranching] helped me allot to get my head around git in general
and how branches, merges and rebasing actually works on an higher abstraction
level. I also started using [ungit] for a more graphical view of my branches,
even though I all the actions trough console.

Deciding what to put in a single commit is also complicated, but the gist of it
is, I think, to have a bunch of commits when writing on an unpublished branch
but to `$ git rebase -i` them into less commits but that still have something
in common. [The thing about git] helped me get much more comfortable with
committing.

I decided to use [git workflow] since I don't have any idea how to organize my
project with git, and it really serves as a good guideline. Because I had many
branches and was not really that much organized in where I commit what it
proved as a good exercise to fix and move things.

## Conclusion

I hope that by going along with this project I will be able to acquire skills
and techniques that will make me a better programmer. Even though it started as
"just an exercise" pretty much from the start I decided to take it seriously
and view it as a opportunity to develop good habits as well.

[LRTHW]: http://learnrubythehardway.org/
[railstutorial]: https://www.railstutorial.org/
[Fear of Programing]: http://www.confreaks.com/videos/1148-rubyconf2008-fear-of-programming
[red-green-refactor]: http://www.jamesshore.com/Blog/Red-Green-Refactor.html
[style guide]: https://github.com/bbatsov/ruby-style-guide
[keep-a-changelog]: https://github.com/olivierlacan/keep-a-changelog
[Pro git]: http://git-scm.com/book/en/v2
[Git workflow]: http://nvie.com/posts/a-successful-git-branching-model/
[LearnGitBranching]: http://pcottle.github.io/learnGitBranching/
[The thing about git]: http://tomayko.com/writings/the-thing-about-git
[ruby koans]: https://github.com/neo/ruby_koans
[rubymonk]: https://rubymonk.com/
[ungit]: https://github.com/FredrikNoren/ungit
[Semantic Versioning]: http://semver.org/
