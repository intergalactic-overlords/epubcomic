require 'fileutils'
require 'zip'
require 'erb'

class Epubcomic
  def self.convert(path)
    @ltr = true
    @title = 'test-title'
    @author = 'test-author'
    @language = 'en'
    @vp_width = '100%'
    @vp_height = '100%'

    # create (hidden) temporary folder
    tmp_dir = 'tmp'
    comics_dir = path
    unless File.exists?(tmp_dir) && File.directory?(tmp_dir)
      FileUtils.mkdir tmp_dir
      FileUtils.mkdir tmp_dir + '/original'
      FileUtils.mkdir tmp_dir + '/working'
      FileUtils.mkdir tmp_dir + '/new'
      FileUtils.mkdir tmp_dir + '/new/META-INF'
      FileUtils.mkdir tmp_dir + '/new/OPS'
      FileUtils.mkdir tmp_dir + '/new/OPS/css'
      FileUtils.mkdir tmp_dir + '/new/OPS/images'
      FileUtils.mkdir tmp_dir + '/new/OPS/xhtml'
    else
      print "tmp dir (#{tmp_dir}) already there?\n"
    end

    # check files in directory/search for cbr or cbz
    Dir.foreach comics_dir do |this_file|
      # some variables

      if File.extname(this_file) === '.cbz'
        # copy file to tmp
        original_file = './' + comics_dir + '/' + this_file
        working_file = './' + tmp_dir + '/original/' + this_file
        FileUtils.cp original_file, working_file

        # unzip on mac - http://sketchucation.com/forums/viewtopic.php?f=180&t=32390
        status = system "unzip -o \"#{working_file}\" -d \"#{tmp_dir}" + "/working" + "\""

        # move images to 'new' folder
        # list images + determine correct order of images
        images = Array.new

        dir = Dir.glob(tmp_dir + '/working/*')
        dir_length = dir.length

        img_dir = tmp_dir + '/working'
        if dir_length == 0
          return error
        elsif dir_length == 1
          img_dir_array = Dir.glob(tmp_dir + '/working/*')
          img_dir = img_dir_array[0]
          if !File.directory?(img_dir)
            return false
          end
        end

        #puts(img_dir)

        Dir.foreach img_dir do |that_file|
          file_types = ['.png', '.jpg', '.jpeg']
          if file_types.include? File.extname(that_file)
            image = {:name => that_file}
            image[:alt] = ""
            image[:ext] = File.extname(that_file)
            type = File.extname(that_file)
            type[0] = ''
            if type == 'jpg'
              type = 'jpeg'
            end
            image[:type] = type
            source = img_dir + '/' + that_file
            destination = tmp_dir + '/new/OPS/images/' + that_file
            FileUtils.mv source, destination
            images.push(image)
          end
        end

        # copy standard files to 'new' folder
        FileUtils.cp 'templates/mimetype', tmp_dir + '/new/mimetype'

        # create custom files and add to 'new' folder
        pages = Array.new

        # xhtml
        @next_spread = 'page-spread-right'
        if not @ltr
          @next_spread = 'page-spread-left'
        end

        images.each do |image|
          page_xhtml = File.open('./templates/OPS/xhtml/page.xhtml.erb', 'r').read
          page_renderer = ERB.new(page_xhtml)
          pagename = 'p' + (image[:name].chomp "jpg") + "xhtml"
          page = {:name => pagename}
          page[:properties] = @next_spread
          if @next_spread == 'page-spread-right'
            @next_spread = 'page-spread-left'
          elsif @next_spread == 'page-spread-left'
            @next_spread = 'page-spread-right'
          end

          pages.push(page)
          path = tmp_dir + '/new/OPS/xhtml/' + pagename
          File.open(path, 'w+') { |file| file.write(page_renderer.result(binding)) }
          #puts renderer.result(binding)
        end

        # toc
        toc_xhtml = File.open('./templates/OPS/xhtml/toc.xhtml.erb', 'r').read
        toc_ncx = File.open('./templates/OPS/xhtml/toc.ncx.erb', 'r').read
        toc_xhtml_renderer = ERB.new(toc_xhtml)
        toc_ncx_renderer = ERB.new(toc_ncx)
        path_toc_xhtml = tmp_dir + '/new/OPS/xhtml/toc.xhtml'
        path_toc_ncx = tmp_dir + '/new/OPS/xhtml/toc.ncx'
        File.open(path_toc_xhtml, 'w+') { |file| file.write(toc_xhtml_renderer.result(binding)) }
        File.open(path_toc_ncx, 'w+') { |file| file.write(toc_ncx_renderer.result(binding)) }

        #package.opf
        package_opf = File.open('./templates/OPS/package.opf.erb', 'r').read
        package_opf_renderer = ERB.new(package_opf)
        path_package_opf = tmp_dir + '/new/OPS/package.opf'
        File.open(path_package_opf, 'w+') { |file| file.write(package_opf_renderer.result(binding)) }

        # css
        FileUtils.cp 'templates/OPS/css/style.css', tmp_dir + '/new/OPS/css/style.css'

        # META-INF/container.xml
        container_xml = File.open('./templates/META-INF/container.xml', 'r').read
        path_container_xml = tmp_dir + '/new/META-INF/container.xml'
        File.open(path_container_xml, 'w+') { |file| file.write(container_xml) }

        # zip and rename epub
        directory = tmp_dir + '/new/'
        zipfile_name = tmp_dir + '/test.epub'

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          Dir[File.join(directory, '**', '**')].each do |file|
            zipfile.add(file.sub(directory, ''), file)
          end
        end
        # move epub to new folder

        # clean up working files

      elsif File.extname(this_file) === '.cbr'
        print 'this is a cbr file'
      end
    end
  end

  # compare size of images

  # check if some images are landscape -> they take up 2 pages

  # create new book

  # place images in epub (one new page per original page)

  # check for metadata

  # add metadata to new book

  # create epub?

  # remove (hidden) temporary folder
  # FileUtils.rm_rf tmp_dir

end