require 'rails_helper'

describe FileTree do
  let(:file_tree) { described_class.new }

  describe '#file_icon' do
    let(:file_icon) { file_tree.send(:file_icon, file) }

    context 'for a media file' do
      context 'for an audio file' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_mp3)) }

        it 'is an audio file icon' do
          expect(file_icon).to include('fa-file-audio-o')
        end
      end

      context 'for an image file' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_jpg)) }

        it 'is an image file icon' do
          expect(file_icon).to include('fa-file-image-o')
        end
      end

      context 'for a video file' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_mp4)) }

        it 'is a video file icon' do
          expect(file_icon).to include('fa-file-video-o')
        end
      end
    end

    context 'for other files' do
      context 'for a read-only file' do
        let(:file) { FactoryGirl.build(:file, read_only: true) }

        it 'is a lock icon' do
          expect(file_icon).to include('fa-lock')
        end
      end

      context 'for an executable file' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_py)) }

        it 'is a code file icon' do
          expect(file_icon).to include('fa-file-code-o')
        end
      end

      context 'for a renderable file' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_svg)) }

        it 'is a text file icon' do
          expect(file_icon).to include('fa-file-text-o')
        end
      end

      context 'for all other files' do
        let(:file) { FactoryGirl.build(:file, file_type: FactoryGirl.build(:dot_md)) }

        it 'is a generic file icon' do
          expect(file_icon).to include('fa-file-o')
        end
      end
    end
  end

  describe '#folder_icon' do
    it 'is a folder icon' do
      expect(file_tree.send(:folder_icon)).to include('fa-folder-o')
    end
  end

  describe '#map_to_js_tree' do
    let(:file) { FactoryGirl.build(:file) }
    let(:js_tree) { file_tree.send(:map_to_js_tree, node) }
    let!(:leaf) { root.add(Tree::TreeNode.new('', file)) }
    let(:root) { Tree::TreeNode.new('', file) }

    context 'for a leaf node' do
      let(:node) { leaf }

      it 'produces the required attributes' do
        expect(js_tree).to include(:icon, :id, :text)
      end

      it 'is enabled' do
        expect(js_tree[:state][:disabled]).to be false
      end

      it 'is closed' do
        expect(js_tree[:state][:opened]).to be false
      end
    end

    context 'for a non-leaf node' do
      let(:node) { root }

      it "traverses the node's children" do
        node.children.each do |child|
          expect(file_tree).to receive(:map_to_js_tree).at_least(:once).with(child).and_call_original
        end
        js_tree
      end

      it 'produces the required attributes' do
        expect(js_tree).to include(:icon, :id, :text)
      end

      it 'is disabled' do
        expect(js_tree[:state][:disabled]).to be true
      end

      it 'is opened' do
        expect(js_tree[:state][:opened]).to be true
      end
    end
  end

  describe '#node_icon' do
    let(:node_icon) { file_tree.send(:node_icon, node) }
    let(:root) { Tree::TreeNode.new('') }

    context 'for the root node' do
      let(:node) { root }

      it 'is a folder icon' do
        expect(node_icon).to eq(file_tree.send(:folder_icon))
      end
    end

    context 'for leaf nodes' do
      let(:node) { root.add(Tree::TreeNode.new('')) }

      it 'is a file icon' do
        expect(file_tree).to receive(:file_icon)
        node_icon
      end
    end

    context 'for intermediary nodes' do
      let(:node) do
        root.add(Tree::TreeNode.new('').tap { |node| node.add(Tree::TreeNode.new('')) })
      end

      it 'is a folder icon' do
        expect(node_icon).to eq(file_tree.send(:folder_icon))
      end
    end
  end

  describe '#to_js_tree' do
    let(:js_tree) { file_tree.to_js_tree }

    it 'returns a String' do
      expect(js_tree).to be_a(String)
    end

    it 'produces the required JSON format' do
      expect(JSON.parse(js_tree).deep_symbolize_keys).to eq(core: {data: file_tree.send(:map_to_js_tree, file_tree)})
    end
  end
end
