require "formula"

class Ambertools14 < Formula
  homepage "http://ambermd.org"
  url "http://ambermd.rutgers.edu/cgi-bin/AmberTools14-get.pl?Name=homebrewer&Institution=0&City=None&State=Other&Country=INT", :using => :post
  sha1 "342ddaca89369f647fe6df78895584d781719375"
  depends_on :fortran
  depends_on :x11 => :optional

  option "with-cuda", 'gpu acceleration'
  option "with-mpi", 'compiler directives for parallelization'
  option "with-openmp", 'message passing for parallelization'
  option "with-no_macAccelerate", 'no mac-specific speedups'

  fails_with :llvm do
      cause <<-EOS.undent
      llvm cannot cross-compile c with fortran in the way amber requires.
      EOS
  end
  fails_with :clang do
      cause <<-EOS.undent
      clang cannot cross-compile c with fortran in the way amber requires.
      EOS
  end
  fails_with :gcc do
      cause <<-EOS.undent
      This version of gcc is not recent enough.
      EOS
  end
  fails_with :gcc => "4.3" do
      cause <<-EOS.undent
      This verison of gcc is not recent enough.
      EOS
  end

  def install
    ENV['AMBERHOME'] = buildpath
    configStr = "echo Y | ./configure"
    configStr += ' -cuda'if build.with? "cuda"
    configStr += ' -mpi'if build.with? "mpi"
    configStr += ' -openmp'if build.with? "openmpi"
    configStr += ' -noX11' if build.without? "x11"
    configStr += ' -macAccelerate' if build.without? "no_macAccelerate"
    configStr += ' gnu'
    system configStr
    system "make", "install"
    bin.install Dir["bin/*"]
    doc.install Dir["doc/*"]
    lib.install Dir["lib/*"]
    include.install Dir["include/*"]
    (prefix/"AmberTools").install Dir["AmberTools/*"]
    (prefix/"test").install Dir["test/*"]
    (prefix/"updateutils").install Dir["updateutils/*"]
  end

  def caveats
      s = <<-EOS.undent
      Using ambertools will require the shell variable AMBERHOME to be set to #{prefix}
      If you are compiling with cuda support, the shell variable CUDA_HOME must be set appropriately.
      EOS
      s
  end

  test do
      system "make test"
  end
end
