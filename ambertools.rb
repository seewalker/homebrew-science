require "formula"

class Ambertools < Formula
  homepage "http://ambermd.org"
  url "http://ambermd.rutgers.edu/cgi-bin/AmberTools14-get.pl?Name=homebrewer&Institution=0&City=None&State=Other&Country=INT", :using => :post
  sha1 "342ddaca89369f647fe6df78895584d781719375"
  version "14"

  depends_on :fortran
  depends_on 'netcdf' => 'enable-fortran'
  depends_on :x11 => :optional
  depends_on :mpi => :optional

  option "with-cuda", 'gpu acceleration'
  option "with-openmp", 'message passing for parallelization'
  option "without-macAccelerate", 'no mac-specific speedups'
  option "with-check", 'directive to run tests after install'

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
    raise "User specified incompatible options" if (build.with? "openmp") and (build.with? "mpi")
    ENV['AMBERHOME'] = buildpath
    inreplace "configure", "read answer", "answer=Y"
    args = []
    args << ' -cuda' if build.with? "cuda"
    args << ' -openmp' if build.with? "openmp"
    args << ' -mpi' if build.with? "mpi"
    args << ' -noX11' if build.without? "x11"
    args << ' -macAccelerate' if build.with? "macAccelerate"
    args << " --with-netcdf #{Formula['netcdf'].prefix}"
    args << " gnu"
    system "./configure", *args
    system "make", "install"
    bin.install Dir["bin/*"]
    doc.install Dir["doc/*"]
    lib.install Dir["lib/*"]
    include.install Dir["include/*"]
    (prefix/"AmberTools").install Dir["AmberTools/*"]
    (prefix/"test").install Dir["test/*"]
    (prefix/"updateutils").install Dir["updateutils/*"]
    system "make test" if build.with? "check"
  end

  def caveats
      s = <<-EOS.undent
      Using ambertools will require the shell variable AMBERHOME to be set to #{prefix}
      If you are compiling with cuda support, the shell variable CUDA_HOME must be set appropriately.
      EOS
      s
  end
end
