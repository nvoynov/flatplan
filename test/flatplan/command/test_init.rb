require_relative '../test_helper'

# NOTE: there is no sesnse to test Read bacause it proxy builder

# Fake reading directory methods
class FakeInit < Flatplan::Command::Init
  def glob_filenames(_directory)
    [ '/home/user/Pictures/image_01.jpg',
      '/home/user/Pictures/image_02.jpg',
      '/home/user/Pictures/image_03.jpg' ]
  end

  FAKE_NEGATIVE = {
    width: 5424,
    height: 3616,
    captured_at: "2017-05-27 19:13:11 +0300",
    title: nil,
    description: nil,
    camera: "SIGMA dp2 Quattro",
    lens: "30mm F2.8"
  }
  
  def call_negatives(_keys)
    glob_filenames(nil)
      .map{ {filename: it}.merge(FAKE_NEGATIVE) }
      .map { [File.basename(it.delete(:filename).to_s, '.*'), it] }
      .to_h
  end
end

describe InitCommand do
  let(:subject) { FakeInit.web }

  it 'dry-run' do
    temp_directory do
      Config.stub :instance, fake_config do
        subject.call(Dir.pwd)#.tap{ puts File.read(it) }
      end
    end
  end
end

__END__

---
title: "D20260830-54679-x2m5uy"
author: "Author"
description: ""
date: ""
---

# MediaAssets
columns: 2
aspect: natural

![](/home/user/Pictures/image_01.jpg)
captured_at: 2017-05-27 19:13:11 +0300
kairos_basic_hint: evening on Saturday [focus], in late spring, 2017

![](/home/user/Pictures/image_02.jpg)
captured_at: 2017-05-27 19:13:11 +0300
kairos_basic_hint: evening on Saturday [focus], in late spring, 2017

![](/home/user/Pictures/image_03.jpg)
captured_at: 2017-05-27 19:13:11 +0300
kairos_basic_hint: evening on Saturday [focus], in late spring, 2017
d20260830-54679-x2m5uy.md
