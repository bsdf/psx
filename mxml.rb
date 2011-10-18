require 'formula'

class Mxml < Formula
  url 'http://ftp.easysw.com/pub/mxml/2.6/mxml-2.6.tar.gz'
  homepage 'http://www.minixml.org/'
  md5 '68977789ae64985dddbd1a1a1652642e'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make"
    system "make install"
  end

  def test
    # This test will fail and we won't accept that! It's enough to just
    # replace "false" with the main program this formula installs, but
    # it'd be nice if you were more thorough. Test the test with
    # `brew test mxml`. Remove this comment before submitting
    # your pull request!
    system "false"
  end
end
