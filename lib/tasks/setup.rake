require 'csv'

namespace :setup do
  desc 'Import teachers from csv file'
  task import_teachers: :environment do
    csv_file_path = 'db/csv/teachers.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      Teacher.create!(name: row['name'], email: row['email'])
      puts 'Added teacher: ' + row['name'] + ' ' + row['email']
    end
  end

  desc 'Import terms from csv file'
  task import_terms: :environment do
    csv_file_path = 'db/csv/terms.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      Term.create!(type: row['type'], year: row['year'])
      puts 'Added term: ' + row['year'] + ' ' + row['type']
    end
  end

  desc 'Import courses from csv file'
  task import_courses: :environment do
    csv_file_path = 'db/csv/courses.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      Course.create!(title: row['title'])
      puts 'Added course: ' + row['title']
    end
  end

  desc 'Import tags from csv file'
  task import_tags: :environment do
    csv_file_path = 'db/csv/tags.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      tag = Tag.create!(title: row['title'])
      tag.courses = Course.where(title: row['courses'].split('&'))
      puts 'Added tag: ' + row['title'] + ' for courses: ' + row['courses']
    end

    CSV.foreach(csv_file_path, headers: true) do |row|
      tag = Tag.find_by(title: row['title'])
      unless row['related_tags'].nil?
        related_ids = Tag.where(title: row['related_tags'].split('&'))
                         .pluck(:id)
        neighbour_ids = tag.neighbours.pluck(:id)
        new_relations = related_ids - neighbour_ids
        tag.related_tags = Tag.where(id: new_relations)
        puts 'Added relation for ' + row['title'] + ':' + row['related_tags']
      end
    end
  end

  desc 'Import lectures from csv file'
  task import_lectures: :environment do
    csv_file_path = 'db/csv/lectures.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      course = Course.find_by(title: row['course'])
      term_data = row['term'].split('&')
      term = Term.where(type: term_data[0], year: term_data[1].to_i).first
      teacher = Teacher.find_by(name: row['teacher'])
      lecture = Lecture.create!(course: course, term: term, teacher: teacher)
      unless row['additional_tags'].nil?
        lecture.additional_tags = Tag.where(title: row['additional_tags']
                                                     .split('&'))
      end
      unless row['disabled_tags'].nil?
        lecture.disabled_tags = Tag.where(title: row['disabled_tags']
                                                   .split('&'))
      end
      puts 'Added lecture: ' + row['course'] + ' ' + row['term'] + ' by: ' +
           row['teacher'] + ' additional_tags: ' + row['additional_tags'].to_s +
           ' disabled_tags:' + row['disabled_tags'].to_s
    end
  end

  desc 'Import chapters from csv file'
  task import_chapters: :environment do
    csv_file_path = 'db/csv/chapters.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      course = Course.find_by(title: row['course'])
      term_data = row['term'].split('&')
      term = Term.where(type: term_data[0], year: term_data[1].to_i).first
      lecture = Lecture.where(course: course, term: term).first
      Chapter.create!(lecture: lecture, number: row['number'].to_i,
                      title: row['title'])
      puts 'Added chapter: ' + row['course'] + ' ' + row['term'] + ' nr: ' +
           row['number'] + ' title: ' + row['title']
    end
  end

  desc 'Import sections from csv file'
  task import_sections: :environment do
    csv_file_path = 'db/csv/sections.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      course = Course.find_by(title: row['course'])
      term_data = row['term'].split('&')
      term = Term.where(type: term_data[0], year: term_data[1].to_i).first
      lecture = Lecture.where(course: course, term: term).first
      chapter = Chapter.where(lecture: lecture, number: row['chapter'].to_i)
                       .first
      section = Section.create(chapter: chapter, number: row['number'],
                               title: row['title'],
                               number_alt: row['number_alt'])
      unless row['tags'].nil?
        section.tags = Tag.where(title: row['tags'].split('&'))
      end
      puts 'Added section: ' + row['course'] + ' ' + row['term'] + ' nr: ' +
           row['number'] + ' title: ' + row['title'] + ' tags: ' + row['tags']
    end
  end

  desc 'Import lessons from csv file'
  task import_lessons: :environment do
    csv_file_path = 'db/csv/lessons.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      course = Course.find_by(title: row['course'])
      term_data = row['term'].split('&')
      term = Term.where(type: term_data[0], year: term_data[1].to_i).first
      lecture = Lecture.where(course: course, term: term).first
      date = Date.new(row['year'].to_i, row['month'].to_i, row['day'].to_i)
      lesson = Lesson.create!(lecture: lecture, number: row['number'].to_i,
                              date: date)
      unless row['tags'].nil?
        lesson.tags = Tag.where(title: row['tags'].split('&'))
      end
      unless row['sections'].nil?
        section_list = row['sections'].split('&').map { |r| r.split('x') }
                                      .map { |x| x.map(&:to_i) }
        section_list.each do |s|
          chapter = Chapter.where(lecture: lecture, number: s[0]).first
          section = Section.where(chapter: chapter, number: s[1])
          lesson.sections << section
        end
      end
      puts 'Added lesson: ' + row['course'] + ' ' + row['term'] + ' nr: ' +
           row['number'] + ' date: ' + date.to_s + 'sections: ' +
           row['sections'] + ' tags:' + row['tags'].to_s
    end
  end

  desc 'Import media from csv file'
  task import_media: :environment do
    csv_file_path = 'db/csv/media.csv'
    base_url = 'https://mampf.mathi.uni-heidelberg.de/'

    CSV.foreach(csv_file_path, headers: true) do |row|
      Medium.create! do |m|
        m.title = row['title']
        m.type = row['type']
        m.author = row['author']
        m.description = row['description']
        m.video_file_link = base_url + row['video_file_link']
        m.video_stream_link = base_url + row['video_stream_link']
        m.video_thumbnail_link = base_url + row['video_thumbnail_link']
        m.manuscript_link = base_url + row['manuscript_link']
        m.external_reference_link = row['external_reference_link']
        m.width = row['width']
        m.height = row['height']
        m.embedded_width = row['embedded_width']
        m.embedded_height = row['embedded_height']
        m.length = row['length']
        m.pages = row['pages']
        m.video_size = row['video_size']
        m.manuscript_size = row['manuscript_size']
        m.authoring_software = row['authoring_software']
      end
      puts 'Added medium: ' + row['title']
    end
  end

  desc 'Import learning_assets from csv file'
  task import_assets: :environment do
    csv_file_path = 'db/csv/learning_assets.csv'

    CSV.foreach(csv_file_path, headers: true) do |row|
      course = Course.find_by(title: row['course'])
      teachable = course
      if row['teachable_type'] != 'Course'
        term_data = row['term'].split('&')
        term = Term.where(type: term_data[0], year: term_data[1].to_i).first
        teachable = Lecture.where(course: course, term: term).first
        if row['teachable_type'] != 'Lecture'
          teachable = Lesson.where(lecture: teachable,
                                   number: row['lesson_number']).first
        end
      end
      LearningAsset.create! do |l|
        l.title = row['title']
        l.type = row['type']
        l.teachable = teachable
        l.heading = row['heading']
        unless row['tags'].nil?
          l.tags = Tag.where(title: row['tags'].split('&'))
        end
        unless row['media'].nil?
          l.media = Medium.where(title: row['media'].split('&'))
        end
      end
      puts 'Added learning_asset: ' + row['title']
    end
  end

  desc 'Resets db and imports all data'
  task import_all: [:environment, 'db:reset', 'setup:import_teachers',
                    'setup:import_terms', 'setup:import_courses',
                    'setup:import_tags', 'setup:import_lectures',
                    'setup:import_chapters', 'setup:import_sections',
                    'setup:import_lessons', 'setup:import_media',
                    'setup:import_assets']
end
