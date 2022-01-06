# typelevel-nix

In antiquity, installing [sbt] was sufficient to compile, test, and run most Scala projects.  sbt would fetch all your JVM dependencies, and you didn't have other dependencies.  There was a [Scala CLR] target, but it was abandoned.

Years passed, and [Scala.js] was born, and we were back to crossing platforms.  We suddenly needed a [Node] installation to run our tests.  More libraries are supporting [Scala Native].  Static site generators outside our JVM bubble have come and gone.

"Faugh," you say.  "The JVM is good enough for me".  Fine, but your libraries target Java 8 for broad appeal and your applications target Java 17 because it's 9 bigger, and you have to juggle multiple JVMs.

Wouldn't it be nice to have one-stop shopping for your development environment again?

## `nix develop` to the rescue

Enter the [Nix] package manager.  We can use [nix develop] to get a full, build enviroment for modern, cross-platform Scala.

For now, you'll need at least Nix 2.4 and to enable the [Nix command].

### The baseline

```console
$ java -version
bash: java: command not found
$ sbt -version
bash: sbt: command not found
$ node --version
bash: node: command not found
```

All my apes gone.

### Library shell

The one-liner `nix develop github:rossabaker/typelevel-nix#library` gets us a full environment:

```console
$ nix develop github:rossabaker/typelevel-nix#library
$ java -version
openjdk version "1.8.0_292"
OpenJDK Runtime Environment (Zulu 8.54.0.21-CA-macosx) (build 1.8.0_292-b10)
OpenJDK 64-Bit Server VM (Zulu 8.54.0.21-CA-macosx) (build 25.292-b10, mixed mode)
$ sbt -version
sbt version in this project: 1.6.1
sbt script version: 1.6.1
$ node --version
v16.13.1
$ exit
```

### Application shell

Alternatively, `nix develop github:rossabaker/typelevel-nix#application` gives us the same, with a more contemporary JDK:

```console
$ nix develop github:rossabaker/typelevel-nix#application
$ java -version
openjdk version "17.0.1" 2021-10-19 LTS
OpenJDK Runtime Environment Zulu17.30+15-CA (build 17.0.1+12-LTS)
OpenJDK 64-Bit Server VM Zulu17.30+15-CA (build 17.0.1+12-LTS, mixed mode, sharing)
$ sbt -version
sbt version in this project: 1.6.1
sbt script version: 1.6.1
$ node --version
v16.13.1
$ exit
```

## Infrequently asked questions

### Is this stable?

Not yet, but flake.lock makes it reproducible.

###	Can I use it with trusty old `nix-shell`?

Probably, but I haven't put time into how.  I'm leaning into flakes.

### What if my library or app requires Java 11?

Uh, we'll expose a library function or something soon.

### Can I embed this in a project to share with my colleagues and collaborators?

Yes.  You should be able to put a `flake.nix` so you can share with your colleagues or open source collaborators, and even provide a [direnv] so your `$SHELL` and `$EDITOR` do the right thing.  Examples forthcoming.

### Does it handle site generators like Jekyll?

Not yet, but it would be great to make that easier.  I've grown fond of [Laika], which doesn't require any of this.

### Is this a Typelevel project?

It's built with Typelevel projects in mind, but this is an individual experiment right now.  If received well, I'll transfer it.

[sbt]: https://www.scala-sbt.org/
[Scala CLR]: https://www.scala-lang.org/old/sites/default/files/pdfs/PreviewScalaNET.pdf
[Scala.js]: https://www.scala-js.org/
[Node]: https://nodejs.org/
[Scala Native]: https://scala-native.readthedocs.io/
[Nix]: https://nixos.org/
[nix develop]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html
[Nix command]: https://nixos.wiki/wiki/Nix_command
[direnv]: https://direnv.net/
[Laika]: https://planet42.github.io/Laika/
