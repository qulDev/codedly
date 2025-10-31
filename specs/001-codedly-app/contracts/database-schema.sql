-- Codedly Mobile App - Supabase Database Schema
-- Version: 1.0.0
-- Created: 2025-10-31
-- Description: Initial schema for Codedly learning platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USER PROFILES TABLE
-- Extends Supabase Auth users with additional profile data
-- ============================================================================

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(100),
    language_preference VARCHAR(5) NOT NULL DEFAULT 'en' CHECK (language_preference IN ('en', 'id')),
    onboarding_completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on email for lookups
CREATE INDEX idx_user_profiles_email ON user_profiles(email);

-- Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================================================
-- USER STATS TABLE
-- Aggregated statistics for fast dashboard queries
-- ============================================================================

CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
    total_xp INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
    current_level INTEGER NOT NULL DEFAULT 1 CHECK (current_level >= 1),
    streak_count INTEGER NOT NULL DEFAULT 0 CHECK (streak_count >= 0),
    last_activity_date DATE,
    lessons_completed INTEGER NOT NULL DEFAULT 0 CHECK (lessons_completed >= 0),
    quizzes_completed INTEGER NOT NULL DEFAULT 0 CHECK (quizzes_completed >= 0),
    modules_completed INTEGER NOT NULL DEFAULT 0 CHECK (modules_completed >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on level for leaderboards (future feature)
CREATE INDEX idx_user_stats_level ON user_stats(current_level DESC);
CREATE INDEX idx_user_stats_xp ON user_stats(total_xp DESC);

-- RLS
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own stats"
    ON user_stats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
    ON user_stats FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats"
    ON user_stats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- MODULES TABLE
-- Learning modules (e.g., "Introduction to Python")
-- ============================================================================

CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_en VARCHAR(200) NOT NULL,
    title_id VARCHAR(200) NOT NULL,
    description_en TEXT,
    description_id TEXT,
    order_index INTEGER NOT NULL UNIQUE CHECK (order_index > 0),
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    estimated_duration_minutes INTEGER CHECK (estimated_duration_minutes > 0),
    required_level INTEGER NOT NULL DEFAULT 1 CHECK (required_level >= 1),
    is_published BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fetching published modules in order
CREATE INDEX idx_modules_published_order ON modules(is_published, order_index) WHERE is_published = true;

-- RLS: All authenticated users can read published modules
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view published modules"
    ON modules FOR SELECT
    USING (is_published = true OR auth.role() = 'authenticated');

-- ============================================================================
-- LESSONS TABLE
-- Individual lessons within modules
-- ============================================================================

CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title_en VARCHAR(200) NOT NULL,
    title_id VARCHAR(200) NOT NULL,
    content_en TEXT NOT NULL,
    content_id TEXT NOT NULL,
    code_template TEXT,
    expected_output TEXT,
    validation_type VARCHAR(20) NOT NULL DEFAULT 'output' CHECK (validation_type IN ('output', 'pattern', 'custom')),
    validation_pattern TEXT,
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    xp_reward INTEGER NOT NULL DEFAULT 10 CHECK (xp_reward > 0),
    estimated_duration_minutes INTEGER CHECK (estimated_duration_minutes > 0),
    is_published BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(module_id, order_index)
);

-- Indexes
CREATE INDEX idx_lessons_module_order ON lessons(module_id, order_index);
CREATE INDEX idx_lessons_published ON lessons(is_published) WHERE is_published = true;

-- RLS
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view published lessons"
    ON lessons FOR SELECT
    USING (is_published = true OR auth.role() = 'authenticated');

-- ============================================================================
-- LESSON HINTS TABLE
-- Hints for lessons
-- ============================================================================

CREATE TABLE lesson_hints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    hint_text_en TEXT NOT NULL CHECK (LENGTH(hint_text_en) >= 10),
    hint_text_id TEXT NOT NULL CHECK (LENGTH(hint_text_id) >= 10),
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(lesson_id, order_index)
);

-- Indexes
CREATE INDEX idx_lesson_hints_lesson_order ON lesson_hints(lesson_id, order_index);

-- RLS
ALTER TABLE lesson_hints ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view hints for published lessons"
    ON lesson_hints FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM lessons 
            WHERE lessons.id = lesson_hints.lesson_id 
            AND lessons.is_published = true
        )
    );

-- ============================================================================
-- QUIZZES TABLE
-- Assessments within modules
-- ============================================================================

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title_en VARCHAR(200) NOT NULL,
    title_id VARCHAR(200) NOT NULL,
    description_en TEXT,
    description_id TEXT,
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    passing_score_percentage INTEGER NOT NULL DEFAULT 70 CHECK (passing_score_percentage >= 0 AND passing_score_percentage <= 100),
    xp_per_correct_answer INTEGER NOT NULL DEFAULT 5 CHECK (xp_per_correct_answer > 0),
    bonus_xp_for_perfect INTEGER NOT NULL DEFAULT 10 CHECK (bonus_xp_for_perfect >= 0),
    is_published BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(module_id, order_index)
);

-- Indexes
CREATE INDEX idx_quizzes_module_order ON quizzes(module_id, order_index);
CREATE INDEX idx_quizzes_published ON quizzes(is_published) WHERE is_published = true;

-- RLS
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view published quizzes"
    ON quizzes FOR SELECT
    USING (is_published = true OR auth.role() = 'authenticated');

-- ============================================================================
-- QUIZ QUESTIONS TABLE
-- Individual questions within quizzes
-- ============================================================================

CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text_en TEXT NOT NULL CHECK (LENGTH(question_text_en) >= 10),
    question_text_id TEXT NOT NULL CHECK (LENGTH(question_text_id) >= 10),
    options_en JSONB NOT NULL,
    options_id JSONB NOT NULL,
    correct_answer_index INTEGER NOT NULL CHECK (correct_answer_index >= 0),
    explanation_en TEXT,
    explanation_id TEXT,
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(quiz_id, order_index)
);

-- Indexes
CREATE INDEX idx_quiz_questions_quiz_order ON quiz_questions(quiz_id, order_index);

-- RLS
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view questions for published quizzes"
    ON quiz_questions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM quizzes 
            WHERE quizzes.id = quiz_questions.quiz_id 
            AND quizzes.is_published = true
        )
    );

-- ============================================================================
-- USER PROGRESS TABLE
-- Tracks completion of lessons and quizzes
-- ============================================================================

CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    content_type VARCHAR(10) NOT NULL CHECK (content_type IN ('lesson', 'quiz')),
    content_id UUID NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    score_percentage INTEGER CHECK (score_percentage >= 0 AND score_percentage <= 100),
    xp_earned INTEGER NOT NULL DEFAULT 0 CHECK (xp_earned >= 0),
    attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
    first_attempted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, content_type, content_id)
);

-- Indexes
CREATE INDEX idx_user_progress_user_completed ON user_progress(user_id, is_completed);
CREATE INDEX idx_user_progress_user_date ON user_progress(user_id, completed_at DESC);
CREATE INDEX idx_user_progress_content ON user_progress(content_type, content_id);

-- RLS
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress"
    ON user_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
    ON user_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
    ON user_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================================================
-- XP RECORDS TABLE
-- Historical log of XP transactions
-- ============================================================================

CREATE TABLE xp_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    xp_amount INTEGER NOT NULL,
    reason VARCHAR(100) NOT NULL CHECK (LENGTH(reason) >= 1),
    content_type VARCHAR(10) CHECK (content_type IN ('lesson', 'quiz', 'bonus')),
    content_id UUID,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_xp_records_user_date ON xp_records(user_id, created_at DESC);
CREATE INDEX idx_xp_records_date ON xp_records(created_at DESC);

-- RLS
ALTER TABLE xp_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own XP records"
    ON xp_records FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own XP records"
    ON xp_records FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- Automatically update updated_at columns
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at
    BEFORE UPDATE ON user_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_modules_updated_at
    BEFORE UPDATE ON modules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quiz_questions_updated_at
    BEFORE UPDATE ON quiz_questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Initialize user stats on profile creation
-- ============================================================================

CREATE OR REPLACE FUNCTION initialize_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_stats (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_initialize_user_stats
    AFTER INSERT ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION initialize_user_stats();

-- ============================================================================
-- SEED DATA: Sample Module and Lessons
-- ============================================================================

-- Insert first module
INSERT INTO modules (
    id,
    title_en,
    title_id,
    description_en,
    description_id,
    order_index,
    difficulty_level,
    estimated_duration_minutes,
    required_level,
    is_published
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Introduction to Python',
    'Pengenalan Python',
    'Learn the basics of Python programming including variables, data types, and basic operations.',
    'Pelajari dasar-dasar pemrograman Python termasuk variabel, tipe data, dan operasi dasar.',
    1,
    'beginner',
    120,
    1,
    true
);

-- Insert sample lessons
INSERT INTO lessons (
    id,
    module_id,
    title_en,
    title_id,
    content_en,
    content_id,
    code_template,
    expected_output,
    validation_type,
    order_index,
    xp_reward,
    is_published
) VALUES 
(
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Your First Python Program',
    'Program Python Pertama Anda',
    '# Welcome to Python!\n\nLet''s start by printing "Hello, World!" to the screen.\n\nIn Python, we use the `print()` function to display text.',
    '# Selamat datang di Python!\n\nMari kita mulai dengan mencetak "Hello, World!" ke layar.\n\nDi Python, kita menggunakan fungsi `print()` untuk menampilkan teks.',
    'print("Hello, World!")',
    'Hello, World!',
    'output',
    1,
    10,
    true
),
(
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000001',
    'Variables and Numbers',
    'Variabel dan Angka',
    '# Variables\n\nVariables store values. Create a variable called `age` and set it to 15.\n\nThen print: "I am 15 years old"',
    '# Variabel\n\nVariabel menyimpan nilai. Buat variabel bernama `age` dan atur ke 15.\n\nKemudian cetak: "I am 15 years old"',
    'age = 15\nprint("I am " + str(age) + " years old")',
    'I am 15 years old',
    'output',
    2,
    10,
    true
);

-- Insert sample hints
INSERT INTO lesson_hints (
    lesson_id,
    hint_text_en,
    hint_text_id,
    order_index
) VALUES 
(
    '10000000-0000-0000-0000-000000000001',
    'Use the print() function with text inside quotes.',
    'Gunakan fungsi print() dengan teks di dalam tanda kutip.',
    1
),
(
    '10000000-0000-0000-0000-000000000002',
    'First, create a variable: age = 15. Then use str(age) to convert the number to text for printing.',
    'Pertama, buat variabel: age = 15. Kemudian gunakan str(age) untuk mengubah angka menjadi teks untuk dicetak.',
    1
);

-- Insert sample quiz
INSERT INTO quizzes (
    id,
    module_id,
    title_en,
    title_id,
    description_en,
    description_id,
    order_index,
    passing_score_percentage,
    xp_per_correct_answer,
    bonus_xp_for_perfect,
    is_published
) VALUES (
    '20000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Python Basics Quiz',
    'Kuis Dasar Python',
    'Test your knowledge of Python basics!',
    'Uji pengetahuan Anda tentang dasar-dasar Python!',
    1,
    70,
    5,
    10,
    true
);

-- Insert sample questions
INSERT INTO quiz_questions (
    quiz_id,
    question_text_en,
    question_text_id,
    options_en,
    options_id,
    correct_answer_index,
    explanation_en,
    explanation_id,
    order_index
) VALUES 
(
    '20000000-0000-0000-0000-000000000001',
    'Which function is used to display output in Python?',
    'Fungsi mana yang digunakan untuk menampilkan output di Python?',
    '["show()", "print()", "display()", "output()"]',
    '["show()", "print()", "display()", "output()"]',
    1,
    'print() is the correct function to display output in Python.',
    'print() adalah fungsi yang benar untuk menampilkan output di Python.',
    1
),
(
    '20000000-0000-0000-0000-000000000001',
    'What symbol is used to assign a value to a variable?',
    'Simbol apa yang digunakan untuk memberikan nilai ke variabel?',
    '[":", "=", "==", "->"]',
    '[":", "=", "==", "->"]',
    1,
    'The = symbol assigns values to variables. == is used for comparison.',
    'Simbol = memberikan nilai ke variabel. == digunakan untuk perbandingan.',
    2
);

-- ============================================================================
-- GRANT PERMISSIONS
-- Allow authenticated users to access tables through RLS policies
-- ============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================================================
-- SCHEMA COMPLETE
-- ============================================================================
