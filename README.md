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

The one-liner `nix develop github:typelevel/typelevel-nix#library` gets us a full environment:

```console
$ nix develop github:typelevel/typelevel-nix#library
🔨 Welcome to typelevel-lib-shell

[general commands]

  menu      - prints this menu
  sbt       - A build tool for Scala, Java and more
  scala-cli - Command-line tool to interact with the Scala language

[versions]

  Java - 8.0.292
  Node - 16.13.1

$ sbt -version
sbt version in this project: 1.6.1
sbt script version: 1.6.1
$ exit
```

### Application shell

Alternatively, `nix develop github:typelevel/typelevel-nix#application` gives us the same, with a more contemporary JDK:

```console
$ nix develop github:typelevel/typelevel-nix#application
🔨 Welcome to typelevel-app-shell

[general commands]

  menu      - prints this menu
  sbt       - A build tool for Scala, Java and more
  scala-cli - Command-line tool to interact with the Scala language

[versions]

  Java - 17.0.1

$ sbt -version
sbt version in this project: 1.6.1
sbt script version: 1.6.1
$ exit
```

### Embed in your project

The `typelevelShell` module can be imported into your `devshell.mkShell` configuration:

```nix
{
  inputs = {
    typelevel-nix.url = "github:typelevel/typelevel-nix";
    nixpkgs.follows = "typelevel-nix/nixpkgs";
    flake-utils.follows = "typelevel-nix/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, typelevel-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ typelevel-nix.overlay ];
        };
      in
      {
        devShell = pkgs.devshell.mkShell {
          imports = [ typelevel-nix.typelevelShell ];
          name = "my-project-shell";
          typelevelShell = {
		    jdk.package = pkgs.jdk8;
			sbtMicrosites = {
			  enable = true;
			  siteDir = ./site;
		    };
          };
        };
      }
    );
}
```

Extra configuration in `typelevelShell`:

* `typelevelShell.jdk.package`: the JDK package to use for `sbt` and the `$JAVA_HOME` environment.  Defaults to `pkgs.jdk17`.  If you're writing a library, you probably want `pkgs.jdk8`.
* `nodejs.enable`: provide NodeJS and Yarn.  Defaults to `true` in the library shell, and `false` elsewhere.
* `typelevelShell.sbtMicrosites.enable`: enables Jekyll support for sbt-microsites.  Defaults to `false`.
* `typelevelShell.sbtMicrosites.siteDir`: directory with your `Gemfile`, `Gemfile.lock`, and `gemset.nix`.  Run [bundix] to create a gemset.nix, and every time you upgrade Jekyll.

## Infrequently asked questions

### Is this stable?

Not yet, but flake.lock makes it reproducible.

###	Can I use it with trusty old `nix-shell`?

Absolutely! The `shell.nix` provides a flakes-compatible shell that works with `nix-shell`. It selects the `application` shell by default, but you can be specific about it. E.g.

```
$ nix-shell --argstr shell library
```

To use it remotely, copy the content of the `shell.nix` in your project and point `src` to this repository instead. E.g.

```nix
{
  src = fetchTarball {
    url = "https://github.com/typelevel/typelevel-nix/archive/main.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # replace hash
  };
};
```

### Can I embed this in a project to share with my colleagues and collaborators?

Yes.  You should be able to put a `flake.nix` so you can share with your colleagues or open source collaborators, and even provide a [direnv] so your `$SHELL` and `$EDITOR` do the right thing.  Examples forthcoming.

### Is this a Typelevel project?

It's built with Typelevel projects in mind, but this is an individual experiment right now.  If received well, I'll transfer it.

### Can I read `.java-version` from jEnv to get an appropriate JDK?

```nix
typelevelShell = {
  jdk.package = builtins.getAttr "jdk${pkgs.lib.fileContents ./.java-version}" pkgs;
}
```

### Is there a binary cache?

Yes.  We are publishing to [typelevel.cachix.org] for Linux and MacOS, though the heavy things are mostly in nixpkgs.

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
[bundix]: https://github.com/nix-community/bundix
[typelevel.cachix.org]: https://app.cachix.org/cache/typelevel#pull
