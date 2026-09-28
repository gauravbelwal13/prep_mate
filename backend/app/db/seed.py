from sqlalchemy import select

from app.db.database import SessionLocal
from app.models.chapter import Chapter
from app.models.exam import Exam
from app.models.exam_subject import ExamSubject
from app.models.question import Question
from app.models.question_exam import QuestionExam
from app.models.question_option import QuestionOption
from app.models.subject import Subject
from app.models.topic import Topic


EXAMS = [
    {
        "code": "NEET",
        "name": "NEET",
        "description": "National Eligibility cum Entrance Test",
    },
    {
        "code": "JEE_MAIN",
        "name": "JEE Main",
        "description": "Joint Entrance Examination Main",
    },
    {
        "code": "JEE_ADVANCED",
        "name": "JEE Advanced",
        "description": "Joint Entrance Examination Advanced",
    },
]


SUBJECTS = [
    {
        "name": "Physics",
        "description": "Physics for competitive entrance examinations.",
    },
    {
        "name": "Chemistry",
        "description": "Chemistry for competitive entrance examinations.",
    },
    {
        "name": "Biology",
        "description": "Biology for medical entrance examinations.",
    },
    {
        "name": "Mathematics",
        "description": "Mathematics for engineering entrance examinations.",
    },
]


EXAM_SUBJECTS = {
    "NEET": [
        "Physics",
        "Chemistry",
        "Biology",
    ],
    "JEE_MAIN": [
        "Physics",
        "Chemistry",
        "Mathematics",
    ],
    "JEE_ADVANCED": [
        "Physics",
        "Chemistry",
        "Mathematics",
    ],
}


CHAPTERS = {
    "Physics": [
        {
            "name": "Units & Measurements",
            "description": "Units, dimensions, errors and measurements.",
        },
        {
            "name": "Kinematics",
            "description": "Motion, displacement, velocity and acceleration.",
        },
        {
            "name": "Laws of Motion",
            "description": "Newton's laws, force, friction and dynamics.",
        },
    ],
    "Chemistry": [
        {
            "name": "Some Basic Concepts of Chemistry",
            "description": "Mole concept, atomic mass and chemical calculations.",
        },
        {
            "name": "Atomic Structure",
            "description": "Atomic models, quantum numbers and electronic structure.",
        },
        {
            "name": "Chemical Bonding",
            "description": "Ionic, covalent bonding and molecular structure.",
        },
    ],
    "Biology": [
        {
            "name": "The Living World",
            "description": "Characteristics of living organisms and taxonomy.",
        },
        {
            "name": "Biological Classification",
            "description": "Classification systems and major biological kingdoms.",
        },
        {
            "name": "Cell Structure",
            "description": "Cell organization, organelles and cellular structure.",
        },
    ],
    "Mathematics": [
        {
            "name": "Sets",
            "description": "Sets, subsets, operations and representations.",
        },
        {
            "name": "Relations & Functions",
            "description": "Relations, functions and their properties.",
        },
        {
            "name": "Quadratic Equations",
            "description": "Roots, equations and properties of quadratic expressions.",
        },
    ],
}


TOPICS = {
    "Units & Measurements": [
        "SI Units",
        "Dimensions",
        "Errors in Measurement",
    ],
    "Kinematics": [
        "Motion in One Dimension",
        "Motion in Two Dimensions",
        "Projectile Motion",
    ],
    "Laws of Motion": [
        "Newton's Laws",
        "Friction",
        "Circular Motion",
    ],
    "Some Basic Concepts of Chemistry": [
        "Mole Concept",
        "Atomic Mass",
        "Stoichiometry",
    ],
    "Atomic Structure": [
        "Atomic Models",
        "Quantum Numbers",
        "Electronic Configuration",
    ],
    "Chemical Bonding": [
        "Ionic Bonding",
        "Covalent Bonding",
        "Molecular Geometry",
    ],
    "The Living World": [
        "Characteristics of Life",
        "Taxonomy",
        "Nomenclature",
    ],
    "Biological Classification": [
        "Five Kingdom Classification",
        "Monera",
        "Protista",
    ],
    "Cell Structure": [
        "Cell Organelles",
        "Cell Membrane",
        "Nucleus",
    ],
    "Sets": [
        "Set Representation",
        "Types of Sets",
        "Set Operations",
    ],
    "Relations & Functions": [
        "Relations",
        "Functions",
        "Types of Functions",
    ],
    "Quadratic Equations": [
        "Roots of Quadratic Equations",
        "Nature of Roots",
        "Quadratic Formula",
    ],
}


QUESTIONS = [
    # ------------------------------------------------------------------
    # PHYSICS - 10 QUESTIONS
    # ------------------------------------------------------------------
    {
        "subject": "Physics",
        "topic": "SI Units",
        "question_text": "Which of the following is the SI unit of electric current?",
        "explanation": "The ampere is the SI base unit of electric current.",
        "options": [
            "Volt",
            "Ampere",
            "Ohm",
            "Coulomb",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Dimensions",
        "question_text": "What is the dimensional formula of velocity?",
        "explanation": "Velocity is displacement divided by time, so its dimensions are L T^-1.",
        "options": [
            "[L T^-1]",
            "[L T^-2]",
            "[M L T^-1]",
            "[M L T^-2]",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Errors in Measurement",
        "question_text": "If a measured quantity has an absolute error of 0.2 cm and its measured value is 10 cm, what is the percentage error?",
        "explanation": "Percentage error = (absolute error / measured value) × 100 = 2%.",
        "options": [
            "0.2%",
            "1%",
            "2%",
            "5%",
        ],
        "correct_option": 2,
        "difficulty": "medium",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Physics",
        "topic": "Motion in One Dimension",
        "question_text": "A body starts from rest and accelerates uniformly at 2 m/s². What is its velocity after 5 seconds?",
        "explanation": "Using v = u + at, v = 0 + (2)(5) = 10 m/s.",
        "options": [
            "5 m/s",
            "10 m/s",
            "12 m/s",
            "20 m/s",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Motion in One Dimension",
        "question_text": "An object moves with constant velocity. Which statement is necessarily true?",
        "explanation": "Constant velocity means both magnitude and direction remain unchanged, so acceleration is zero.",
        "options": [
            "Its acceleration is constant and non-zero",
            "Its acceleration is zero",
            "Its speed continuously increases",
            "Its displacement is always zero",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Physics",
        "topic": "Projectile Motion",
        "question_text": "At the highest point of an ideal projectile's path, its vertical velocity component is:",
        "explanation": "The vertical component of velocity becomes zero momentarily at the highest point.",
        "options": [
            "Maximum",
            "Equal to horizontal velocity",
            "Zero",
            "Equal to acceleration",
        ],
        "correct_option": 2,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Newton's Laws",
        "question_text": "According to Newton's second law, the net force on an object is equal to:",
        "explanation": "Newton's second law gives F = ma for constant mass.",
        "options": [
            "Mass divided by acceleration",
            "Mass multiplied by acceleration",
            "Velocity multiplied by mass",
            "Momentum divided by mass",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Friction",
        "question_text": "Friction acting between two surfaces generally opposes:",
        "explanation": "Friction opposes relative motion or the tendency of relative motion between contacting surfaces.",
        "options": [
            "Gravity",
            "Normal force",
            "Relative motion",
            "Mass",
        ],
        "correct_option": 2,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Physics",
        "topic": "Circular Motion",
        "question_text": "For uniform circular motion, the magnitude of velocity is:",
        "explanation": "In uniform circular motion, speed remains constant while the direction of velocity changes.",
        "options": [
            "Constant",
            "Always zero",
            "Continuously increasing",
            "Continuously decreasing",
        ],
        "correct_option": 0,
        "difficulty": "medium",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Physics",
        "topic": "Circular Motion",
        "question_text": "The centripetal acceleration of an object moving in a circle of radius r with speed v is:",
        "explanation": "Centripetal acceleration is directed toward the center and has magnitude v²/r.",
        "options": [
            "vr",
            "v/r",
            "v²/r",
            "r²/v",
        ],
        "correct_option": 2,
        "difficulty": "medium",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },

    # ------------------------------------------------------------------
    # CHEMISTRY - 10 QUESTIONS
    # ------------------------------------------------------------------
    {
        "subject": "Chemistry",
        "topic": "Mole Concept",
        "question_text": "How many particles are approximately present in one mole of a substance?",
        "explanation": "One mole contains Avogadro's number of particles, approximately 6.022 × 10²³.",
        "options": [
            "6.022 × 10²⁰",
            "6.022 × 10²¹",
            "6.022 × 10²²",
            "6.022 × 10²³",
        ],
        "correct_option": 3,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Chemistry",
        "topic": "Atomic Mass",
        "question_text": "The atomic mass unit is commonly defined relative to which isotope?",
        "explanation": "One atomic mass unit is defined as one-twelfth of the mass of a carbon-12 atom.",
        "options": [
            "Hydrogen-1",
            "Carbon-12",
            "Oxygen-16",
            "Nitrogen-14",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Chemistry",
        "topic": "Stoichiometry",
        "question_text": "In a balanced chemical equation, the coefficients primarily represent ratios of:",
        "explanation": "Coefficients in a balanced equation give the relative molar amounts of reactants and products.",
        "options": [
            "Atomic radii",
            "Molar quantities",
            "Electron speeds",
            "Densities",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Chemistry",
        "topic": "Mole Concept",
        "question_text": "How many moles are present in 18 g of water, assuming its molar mass is 18 g/mol?",
        "explanation": "Number of moles = mass / molar mass = 18 / 18 = 1 mole.",
        "options": [
            "0.5 mol",
            "1 mol",
            "2 mol",
            "18 mol",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Chemistry",
        "topic": "Atomic Models",
        "question_text": "Which atomic model introduced the idea of electrons embedded in a positively charged sphere?",
        "explanation": "J. J. Thomson proposed the plum pudding model.",
        "options": [
            "Rutherford model",
            "Bohr model",
            "Thomson model",
            "Quantum mechanical model",
        ],
        "correct_option": 2,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Chemistry",
        "topic": "Quantum Numbers",
        "question_text": "Which quantum number describes the shape of an orbital?",
        "explanation": "The azimuthal quantum number, l, determines the subshell and orbital shape.",
        "options": [
            "Principal quantum number",
            "Azimuthal quantum number",
            "Magnetic quantum number",
            "Spin quantum number",
        ],
        "correct_option": 1,
        "difficulty": "medium",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Chemistry",
        "topic": "Electronic Configuration",
        "question_text": "How many electrons can occupy an orbital at maximum?",
        "explanation": "According to the Pauli exclusion principle, an orbital can contain at most two electrons with opposite spins.",
        "options": [
            "1",
            "2",
            "4",
            "6",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Chemistry",
        "topic": "Ionic Bonding",
        "question_text": "An ionic bond is primarily formed through:",
        "explanation": "Ionic bonding involves electron transfer followed by electrostatic attraction between oppositely charged ions.",
        "options": [
            "Sharing of identical nuclei",
            "Transfer of electrons",
            "Sharing of neutrons",
            "Fusion of atoms",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN"],
    },
    {
        "subject": "Chemistry",
        "topic": "Covalent Bonding",
        "question_text": "A covalent bond is generally formed by:",
        "explanation": "Covalent bonding involves sharing of electron pairs between atoms.",
        "options": [
            "Transfer of protons",
            "Sharing of electrons",
            "Loss of neutrons",
            "Transfer of atomic nuclei",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Chemistry",
        "topic": "Molecular Geometry",
        "question_text": "What is the approximate bond angle in a linear molecule?",
        "explanation": "Two bonding directions arranged linearly form an angle of 180°.",
        "options": [
            "90°",
            "109.5°",
            "120°",
            "180°",
        ],
        "correct_option": 3,
        "difficulty": "easy",
        "exams": ["NEET", "JEE_MAIN", "JEE_ADVANCED"],
    },

    # ------------------------------------------------------------------
    # BIOLOGY - 10 QUESTIONS
    # ------------------------------------------------------------------
    {
        "subject": "Biology",
        "topic": "Characteristics of Life",
        "question_text": "Which characteristic is commonly used as a fundamental feature of living organisms?",
        "explanation": "Living organisms exhibit characteristics such as metabolism, growth, reproduction and response to stimuli.",
        "options": [
            "Metabolism",
            "Crystallization",
            "Rusting",
            "Evaporation",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Taxonomy",
        "question_text": "The branch of biology concerned with identification, nomenclature and classification is called:",
        "explanation": "Taxonomy deals with identification, naming and classification of organisms.",
        "options": [
            "Ecology",
            "Taxonomy",
            "Physiology",
            "Histology",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Nomenclature",
        "question_text": "In binomial nomenclature, the scientific name of an organism consists primarily of:",
        "explanation": "A binomial scientific name contains the genus name followed by the specific epithet.",
        "options": [
            "Family and order",
            "Genus and specific epithet",
            "Kingdom and class",
            "Species and kingdom",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Five Kingdom Classification",
        "question_text": "Which kingdom includes organisms such as bacteria in the traditional five-kingdom classification?",
        "explanation": "In the five-kingdom system, bacteria are placed in Kingdom Monera.",
        "options": [
            "Plantae",
            "Animalia",
            "Monera",
            "Fungi",
        ],
        "correct_option": 2,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Monera",
        "question_text": "Organisms belonging to Kingdom Monera are generally:",
        "explanation": "Monerans are prokaryotic organisms lacking a membrane-bound nucleus.",
        "options": [
            "Prokaryotic",
            "Multicellular eukaryotic only",
            "Acellular",
            "Always photosynthetic",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Protista",
        "question_text": "Members of Kingdom Protista are generally:",
        "explanation": "Protists are predominantly unicellular eukaryotic organisms.",
        "options": [
            "Prokaryotic",
            "Unicellular eukaryotic",
            "Multicellular prokaryotic",
            "Always non-cellular",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Cell Organelles",
        "question_text": "Which organelle is primarily associated with ATP production in eukaryotic cells?",
        "explanation": "Mitochondria are the major sites of aerobic cellular respiration and ATP production.",
        "options": [
            "Ribosome",
            "Mitochondrion",
            "Golgi apparatus",
            "Lysosome",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Cell Membrane",
        "question_text": "The cell membrane is primarily composed of:",
        "explanation": "The cell membrane contains a phospholipid bilayer with embedded proteins.",
        "options": [
            "Only carbohydrates",
            "Lipids and proteins",
            "Only nucleic acids",
            "Only minerals",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Nucleus",
        "question_text": "Which structure contains most of the genetic material in a typical eukaryotic cell?",
        "explanation": "The nucleus contains the majority of the cell's DNA organized into chromosomes.",
        "options": [
            "Nucleus",
            "Cell wall",
            "Golgi apparatus",
            "Vacuole",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["NEET"],
    },
    {
        "subject": "Biology",
        "topic": "Cell Organelles",
        "question_text": "Which organelle is directly responsible for protein synthesis?",
        "explanation": "Ribosomes are the cellular structures responsible for translation and protein synthesis.",
        "options": [
            "Ribosome",
            "Lysosome",
            "Centrosome",
            "Vacuole",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["NEET"],
    },

    # ------------------------------------------------------------------
    # MATHEMATICS - 10 QUESTIONS
    # ------------------------------------------------------------------
    {
        "subject": "Mathematics",
        "topic": "Set Representation",
        "question_text": "Which notation is commonly used to represent the set of natural numbers?",
        "explanation": "A common notation is N = {1, 2, 3, ...}, although conventions may vary regarding whether zero is included.",
        "options": [
            "N",
            "Z",
            "Q",
            "R",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Types of Sets",
        "question_text": "A set containing no elements is called:",
        "explanation": "A set with no elements is called the empty or null set.",
        "options": [
            "Universal set",
            "Singleton set",
            "Empty set",
            "Infinite set",
        ],
        "correct_option": 2,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Set Operations",
        "question_text": "If A = {1, 2, 3} and B = {3, 4, 5}, what is A ∩ B?",
        "explanation": "The intersection contains elements common to both sets. Here, only 3 is common.",
        "options": [
            "{1, 2}",
            "{3}",
            "{4, 5}",
            "{1, 2, 3, 4, 5}",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Set Operations",
        "question_text": "If A and B are disjoint sets, their intersection is:",
        "explanation": "Disjoint sets have no common elements, so their intersection is the empty set.",
        "options": [
            "A",
            "B",
            "A ∪ B",
            "∅",
        ],
        "correct_option": 3,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Relations",
        "question_text": "A relation from set A to set B is a subset of:",
        "explanation": "A relation from A to B is any subset of the Cartesian product A × B.",
        "options": [
            "A ∪ B",
            "A × B",
            "A − B",
            "B − A",
        ],
        "correct_option": 1,
        "difficulty": "medium",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Functions",
        "question_text": "For a function f: A → B, every element of A must be associated with:",
        "explanation": "A function assigns exactly one element of the codomain to every element of its domain.",
        "options": [
            "At least two elements of B",
            "Exactly one element of B",
            "No element of B",
            "Every element of B",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Types of Functions",
        "question_text": "A function in which distinct elements of the domain have distinct images is called:",
        "explanation": "Such a function is one-to-one, also called injective.",
        "options": [
            "Constant",
            "Injective",
            "Periodic",
            "Zero function",
        ],
        "correct_option": 1,
        "difficulty": "medium",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Roots of Quadratic Equations",
        "question_text": "What are the roots of x² − 5x + 6 = 0?",
        "explanation": "The equation factors as (x − 2)(x − 3) = 0, giving roots 2 and 3.",
        "options": [
            "1 and 6",
            "2 and 3",
            "-2 and -3",
            "3 and 6",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Nature of Roots",
        "question_text": "For a quadratic equation ax² + bx + c = 0, the discriminant is:",
        "explanation": "The discriminant is D = b² − 4ac and determines the nature of the roots.",
        "options": [
            "b² + 4ac",
            "b² − 4ac",
            "4ac − b",
            "a² − 4bc",
        ],
        "correct_option": 1,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
    {
        "subject": "Mathematics",
        "topic": "Quadratic Formula",
        "question_text": "Which expression gives the roots of ax² + bx + c = 0?",
        "explanation": "The quadratic formula is x = (-b ± √(b² − 4ac)) / 2a.",
        "options": [
            "(-b ± √(b² − 4ac)) / 2a",
            "(b ± √(b² + 4ac)) / 2a",
            "(-a ± √(a² − 4bc)) / 2b",
            "(a ± √(b² − 4ac)) / 2c",
        ],
        "correct_option": 0,
        "difficulty": "easy",
        "exams": ["JEE_MAIN", "JEE_ADVANCED"],
    },
]


def seed_exams(db) -> dict[str, Exam]:
    exams: dict[str, Exam] = {}

    for exam_data in EXAMS:
        exam = db.execute(
            select(Exam).where(
                Exam.code == exam_data["code"],
            )
        ).scalar_one_or_none()

        if exam is None:
            exam = Exam(
                code=exam_data["code"],
                name=exam_data["name"],
                description=exam_data["description"],
                is_active=True,
            )

            db.add(exam)
            db.flush()

        exams[exam.code] = exam

    return exams


def seed_subjects(db) -> dict[str, Subject]:
    subjects: dict[str, Subject] = {}

    for subject_data in SUBJECTS:
        subject = db.execute(
            select(Subject).where(
                Subject.name == subject_data["name"],
            )
        ).scalar_one_or_none()

        if subject is None:
            subject = Subject(
                name=subject_data["name"],
                description=subject_data["description"],
                is_active=True,
            )

            db.add(subject)
            db.flush()

        subjects[subject.name] = subject

    return subjects


def seed_exam_subjects(
    db,
    exams: dict[str, Exam],
    subjects: dict[str, Subject],
) -> None:
    for exam_code, subject_names in EXAM_SUBJECTS.items():
        exam = exams[exam_code]

        for subject_name in subject_names:
            subject = subjects[subject_name]

            mapping = db.execute(
                select(ExamSubject).where(
                    ExamSubject.exam_id == exam.id,
                    ExamSubject.subject_id == subject.id,
                )
            ).scalar_one_or_none()

            if mapping is None:
                db.add(
                    ExamSubject(
                        exam_id=exam.id,
                        subject_id=subject.id,
                    )
                )

    db.flush()


def seed_chapters(
    db,
    subjects: dict[str, Subject],
) -> dict[str, Chapter]:
    chapters: dict[str, Chapter] = {}

    for subject_name, chapter_data_list in CHAPTERS.items():
        subject = subjects[subject_name]

        for index, chapter_data in enumerate(
            chapter_data_list,
            start=1,
        ):
            chapter = db.execute(
                select(Chapter).where(
                    Chapter.subject_id == subject.id,
                    Chapter.name == chapter_data["name"],
                )
            ).scalar_one_or_none()

            if chapter is None:
                chapter = Chapter(
                    subject_id=subject.id,
                    name=chapter_data["name"],
                    description=chapter_data["description"],
                    sort_order=index,
                    is_active=True,
                )

                db.add(chapter)
                db.flush()

            chapters[chapter.name] = chapter

    return chapters


def seed_topics(
    db,
    chapters: dict[str, Chapter],
) -> dict[str, Topic]:
    topics: dict[str, Topic] = {}

    for chapter_name, topic_names in TOPICS.items():
        chapter = chapters[chapter_name]

        for index, topic_name in enumerate(
            topic_names,
            start=1,
        ):
            topic = db.execute(
                select(Topic).where(
                    Topic.chapter_id == chapter.id,
                    Topic.name == topic_name,
                )
            ).scalar_one_or_none()

            if topic is None:
                topic = Topic(
                    chapter_id=chapter.id,
                    name=topic_name,
                    sort_order=index,
                    is_active=True,
                )

                db.add(topic)
                db.flush()

            topics[topic.name] = topic

    return topics


def get_or_create_question(
    db,
    topic: Topic,
    question_data: dict,
) -> Question:
    question = db.execute(
        select(Question).where(
            Question.topic_id == topic.id,
            Question.question_text == question_data["question_text"],
        )
    ).scalar_one_or_none()

    if question is None:
        question = Question(
            topic_id=topic.id,
            question_text=question_data["question_text"],
            explanation=question_data["explanation"],
            question_type="mcq",
            image_url=question_data.get("image_url"),
            source="PrepMate development seed",
            status="published",
        )

        db.add(question)
        db.flush()

        for option_order, option_text in enumerate(
            question_data["options"],
            start=1,
        ):
            db.add(
                QuestionOption(
                    question_id=question.id,
                    option_order=option_order,
                    option_text=option_text,
                    is_correct=(
                        option_order - 1
                        == question_data["correct_option"]
                    ),
                )
            )

        db.flush()

    return question


def seed_question_exams(
    db,
    question: Question,
    question_data: dict,
    exams: dict[str, Exam],
) -> None:
    for exam_code in question_data["exams"]:
        exam = exams[exam_code]

        mapping = db.execute(
            select(QuestionExam).where(
                QuestionExam.question_id == question.id,
                QuestionExam.exam_id == exam.id,
            )
        ).scalar_one_or_none()

        if mapping is None:
            db.add(
                QuestionExam(
                    question_id=question.id,
                    exam_id=exam.id,
                    difficulty=question_data.get(
                        "difficulty",
                        "medium",
                    ),
                    marks=4,
                    negative_marks=1,
                    is_active=True,
                )
            )

    db.flush()


def seed_questions(
    db,
    topics: dict[str, Topic],
    exams: dict[str, Exam],
) -> None:
    for question_data in QUESTIONS:
        topic_name = question_data["topic"]

        if topic_name not in topics:
            raise ValueError(
                f"Topic '{topic_name}' does not exist."
            )

        topic = topics[topic_name]

        question = get_or_create_question(
            db=db,
            topic=topic,
            question_data=question_data,
        )

        seed_question_exams(
            db=db,
            question=question,
            question_data=question_data,
            exams=exams,
        )


def seed_academic_content() -> None:
    db = SessionLocal()

    try:
        exams = seed_exams(db)

        subjects = seed_subjects(db)

        seed_exam_subjects(
            db=db,
            exams=exams,
            subjects=subjects,
        )

        chapters = seed_chapters(
            db=db,
            subjects=subjects,
        )

        topics = seed_topics(
            db=db,
            chapters=chapters,
        )

        seed_questions(
            db=db,
            topics=topics,
            exams=exams,
        )

        db.commit()

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_academic_content()
    print("Academic content and question seed completed.")