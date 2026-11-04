
:-set_prolog_flag(encoding,utf8).
:- encoding(utf8).
:-[universities, departments, courses, books, books_per_course].

/*
run/     run
Το κατηγορημα run/ χρησιμοποιηται αποκληστικα για την εκκινηση του προγραμματος και την εναρξη του κυριους κατηγορηματος του προγραμματος run2/ εντος της catch/3.
Ο μονος λογος υπαρξης του, ειναι για τον τερματισμο λειτουργιας του προγραμματος με εξοδο true
*/

run:-
    catch(run2,exit_command,true).

/*
run2/     run2
Το run2/ ειναι  το κυριο κατηγορημα του προγραμματος.
Εμφανιζει αρχικα το μενου επιλογων,διαβαζει την επιλογη του χρηστη και και καλει ενα συνολο υποκατηγορηματων, το καθενα απο τα οποια αντιστοιχει σε μια πιθανη επιλογη του χρηστη.
Ολες τα υποκατηγορηματα ειναι σχεδιασμενα να εκτελουν τις σχετικες τους λειτουργιες οταν τα επιλεγει ο χρηστης και να επιστρεφουν true οταν δεν τα επιλεγει.
Με αυτο το τροπο μπορουν να καλουντε ολα την ιδια στιγμη χωρις να τερματιζει το προγραμμα.
Στο τελος το κατηγορημα καλει τον εαυτο του επαναλαμβανοντας ετσι την διαδικασια
*/
run2:-
    prompt1(''),  
    write("Μενού:\n======\n\n1 - Στατιστικά και διάθεση βιβλίου για 1 έτος\n2 - Στατιστικά βιβλίου για πολλαπλά έτη\n3 - Σύγκριση στατιστικών και διάθεσης βιβλίου μεταξύ 2 ετών\n4 - Σύγκριση στατιστικών 2 βιβλίων για 1 έτος\n5 - Σύγκριση 2 βιβλίων: Πανεπιστήμια που διατίθεται το 1ο σε σχέση με το 2ο\n6 - Σύγκριση 2 βιβλίων: Τμήματα που διατίθεται το 1ο σε σχέση με το 2ο\n7 - Σύγκριση 2 βιβλίων: Μαθήματα που διατίθεται το 1ο σε σχέση με το 2ο\n0 - Έξοδος\n\nΕπιλογή: |: "),
    read(X),
    write("\n"),
    book_statistics_1_year(X),
    book_statistics_consecutive_years(X),
    one_book_two_year_comparison(X),
    two_book_one_year_comparison(X),
    two_book_university_comparison(X),
    two_book_department_comparison(X),
    two_book_courses_comparison(X),
    exit(X),
    wrong_option(X),
    write("\n\n"),
    run2.

/*
book_statistics_1_year/1     book_statistics_1_year(Choice)
Το book_statistics_1_year/1 υλοποιει την πρωτη επιλογη του μενου.
Αρχικα διαβαζει απο τον χρηστη το ζητουμενο βιβλιο την ζητουμενη χρονια και απο εκει, μεσω των ετοιμων κατηγορηματων, βρισκει τα αντιστοιχα μαθηματα,τμηματα και πανεπιστημια.
Υστερα αφαρει τα αντιγραφα τμηματων και πανεπιστημιων και με το filter_courses_by_department/4 διαγραφει τα μαθηματα με διαφορετικο ID που προσφερονται την ιδια χρονια,στο ιδιο τημα,με ιδιο ονομα.
Εμφανιζει τα αποτελεσματα καλωντας το print_departments/2 και ταυτοχρονα  υπολογιζει και εκτυπωνει τον αριθμο των μαθηματων, τμηματων και πανεπιστημιων που βρηκε
*/

book_statistics_1_year(X):-
    X==1,
    write("\nΣτατιστικά και διάθεση βιβλίου για 1 έτος\n=========================================\nΔώσε τον κωδικό του βιβλίου\n"),
    read(BookID),
    write("Δώσε το έτος\n"),
    read(Year),
    book_check(BookID),
    book(BookID,BookName),
    format("\nΒιβλίο: ~w - ~w\n\n",[BookID,BookName]),
    findall(CourseID,course_book(CourseID,BookID),CourseIDListAllYears),
    findall(CourseID,(member(CourseID,CourseIDListAllYears),course(CourseID,_,Year,_)),CourseIDList),
    findall(DepartmentID,(member(CourseID,CourseIDListAllYears),course(CourseID,_,Year,DepartmentID)),DepartmentIDListUnsorted),
    sort(DepartmentIDListUnsorted,DepartmentIDList),
    findall(UniversityID,(member(DepartmentID,DepartmentIDList),department(DepartmentID,_,university(UniversityID))),UniversityIDList),
    sort(UniversityIDList,UniversityIDListSorted),
    filter_courses_by_department(CourseIDList,DepartmentIDList,Year,CourseIDListFiltered),
    print_departments(DepartmentIDList,CourseIDListFiltered),
    length(CourseIDListFiltered,CoursesAmount),
    length(DepartmentIDList,DepartmentsAmount),
    length(UniversityIDListSorted,UniversitiesAmount),
    format("Συνολικός Αριθμός Πανεπιστημίων: ~w\nΣυνολικός Αριθμός Τμημάτων: ~w\nΣυνολικός Αριθμός Μαθημάτων: ~w",[UniversitiesAmount,DepartmentsAmount,CoursesAmount]).

book_statistics_1_year(_).

/*
find_courses/4    find_courses([Courses],DepartmentID,[MatchingCourses],Year)
Το βοηθητικο κατηγορημα find_courses/4 δεχεται μια λιστα μαθηματων,ενα τμημα,μια χρονια και δημιουργει μια νεα λιστα μαθηματων η οποια αποτελειται απο οσα μαθηματα της πρωτης λιστας προσφερθηκαν στο συκεκριμενο τμημα,την συγκεκριμενη χρονια
Το κατηγορημα λειτουργει αναδρομικα εξεταζοντας ενα ενα τα μαθηματα και αποφασιζοντας αν πρεπει να προστεθουν στην λιστα
*/

find_courses([],_,[],_).
find_courses([Course|RestCourses],DepID,[Course|RestMatchingCourses],Year):-
    course(Course,_,Year,DepID),
    !,
    find_courses(RestCourses,DepID,RestMatchingCourses,Year).

find_courses([_Course|RestCourses],DepID,RestMatchingCourses,Year):-
    find_courses(RestCourses,DepID,RestMatchingCourses,Year).

/*
book_statistics_consecutive_years/1    book_statistics_consecutive_years(Option)
Το book_statistics_consecutive_years/1 ειναι το κατηγορημα που υλοποιει την δευτερη επιλογη
Αφου διαβασει απο τον χρηστη εναν κωδικο βιβλιου και δυο χρονιες εκτυπωνει τα στατιστικα του βιβλιου για καθε ενδιαμεσο ετος μεσω του βοηθητικου κατηγορηματος print_statistics_over_years/3
*/

book_statistics_consecutive_years(X):-X==2,
    write("\nΣτατιστικά και διάθεση βιβλίου για πολλαπλά έτη\n=========================================\nΔώσε τον κωδικό του βιβλίου\n"),
    read(BookID),
    write("Δώσε το αρχικό έτος\n"),
    read(YearStart),
    write("\nΔώσε το τελικό έτος\n"),
    read(YearEnd),
    book_check(BookID),
    book(BookID,BookName),
    format("\nΒιβλίο: ~w - ~w\n\n",[BookID,BookName]),
    write("Έτος          Πανεπιστήμια     Τμήματα     Μαθήματα\n"),
    print_statistics_over_years(BookID,YearStart,YearEnd).

book_statistics_consecutive_years(_).

/*
print_statistics_over_years/3      print_statistics_over_years(BookID,StartingYear,EndingYear)
Το print_statistics_over_years/3 παιρνει ενα βιβλιο και απο μια αρχικη εως μια τελικη χρονια βρισκει με το statistics_sum_1_year/5 τα βασικα στατιστικα του βιβλιου και τα εκτυπωνει
*/

print_statistics_over_years(_Book,Year1,Year2):-
    Year1>=Year2,
    !.
print_statistics_over_years(Book,Year1,Year2):-
    Year1<Year2,
    statistics_sum_1_year(Book,Year1,UniversitiesSum,DepartmentSum,CourseSum),
    YearNext is Year1+1,
    format("~w-~w~t~w~16|~t~w~33|~t~w~45|\n",[Year1,YearNext,UniversitiesSum,DepartmentSum,CourseSum]),
    print_statistics_over_years(Book,YearNext,Year2).

/*
statistics_sum_1_year/5       statistics_sum_1_year(BookID,Year,NumberOfUniversities,NumberOfDepartments,NumberOfCourses)
Το statistics_sum_1_year/5 υπολογιζει το συνολο των μαθηματων,τμηματων και πανεπιστημιων ενος βιβλιου για μια συκεκριμενη χρονια
*/

statistics_sum_1_year(Book,Year,UniversitiesSum,DepartmentSum,CourseSum):-
    findall(CourseID,course_book(CourseID,Book),BookCourses),
    findall(CourseID,course(CourseID,_,Year,_),YearCourses),
    intersection(BookCourses,YearCourses,Courses),
    findall(DepartmentID,(member(CourseID,Courses),course(CourseID,_,Year,DepartmentID)),Departments),
    findall(UniversityID,(member(DepartmentID,Departments),department(DepartmentID,_,university(UniversityID))),Universities),
    sort(Departments,DepartmentsSorted),
    sort(Universities,UniversitiesSorted),
    filter_courses_by_department(Courses,DepartmentsSorted,Year,FilteredCourses),
    length(FilteredCourses,CourseSum),
    length(DepartmentsSorted,DepartmentSum),
    length(UniversitiesSorted,UniversitiesSum).

/*
one_book_tow_year_comparison/1         one_book_tow_year_comparison(Option)
Το one_book_tow_year_comparison/1 υλοποιει την τριτη επιλογη
Διαβαζει ενα βιβλιο και δυο χρονιες και βρισκει τα μαθηματα,τμηματα και τα πανεπιστημια του βιλιου αυτου για τις δυο ανιστοιχες χρονιες
Αφαιροντας το συνολα της μιας χρονιας απο την αλλη και αντιστροφα βρισκει οτι αντικειμενα προστεθηκαν,και οτι αφαιρεθηκαν
Τα εμφανιζει αυτα με αντιστοιχα βοηθητικα κατηγορηματα
*/

one_book_two_year_comparison(X):-
    X==3,
    write("\nΣύγκριση στατιστικών και διάθεσης βιβλίου μεταξύ 2 ετών\n=======================================================\nΔώσε τον κωδικό του βιβλίου\n"),
    read(BookID),
    write("Δώσε το πρώτο έτος\n"),
    read(Year1),
    write("\nΔώσε το δεύτερο έτος\n"),
    read(Year2),
    book_check(BookID),
    book(BookID,BookName),
    format("\nΒιβλίο: ~w - ~w\n\n\n",[BookID,BookName]),
    findall(CourseID,(course_book(CourseID,BookID),course(CourseID,_,Year1,_)),Courses1),
    sort(Courses1,Courses1Sorted),
    findall(DepartmentID,(member(CourseID,Courses1Sorted),course(CourseID,_,Year1,DepartmentID)),Departments1),
    sort(Departments1,Departments1Sorted),
    filter_courses_by_department(Courses1Sorted,Departments1Sorted,Year1,Courses1Filtered),
    findall(CourseID,(course_book(CourseID,BookID),course(CourseID,_,Year2,_)),Courses2),
    sort(Courses2,Courses2Sorted),
    findall(DepartmentID,(member(CourseID,Courses2Sorted),course(CourseID,_,Year2,DepartmentID)),Departments2),
    sort(Departments2,Departments2Sorted),
    filter_courses_by_department(Courses2Sorted,Departments2Sorted,Year2,Courses2Filtered),
    course_list_remover(Courses1Filtered,Courses2Filtered,RemovedCourses),
    course_list_remover(Courses2Filtered,Courses1Filtered,AddedCourses),
    NextYear1 is Year1+1,
    NextYear2 is Year2+1,
    subtract(Departments1Sorted,Departments2Sorted,RemovedDepartments),
    subtract(Departments2Sorted,Departments1Sorted,AddedDepartments),
    findall(UniversityID,(member(DepartmentID,Departments1Sorted),department(DepartmentID,_,university(UniversityID))),Universities1),
    findall(UniversityID,(member(DepartmentID,Departments2Sorted),department(DepartmentID,_,university(UniversityID))),Universities2),
    sort(Universities1,Universities1Sorted),
    sort(Universities2,Universities2Sorted),
    subtract(Universities1Sorted,Universities2Sorted,RemovedUniversities),
    subtract(Universities2Sorted,Universities1Sorted,AddedUniversities),
    format("Αφαιρέθηκαν το ~w-~w σε σχέση με το ~w-~w:\n\n",[Year2,NextYear2,Year1,NextYear1]),
    write("Πανεπιστήμια:\n"),
    print_universities(RemovedUniversities,RemovedDepartments,RemovedCourses),
    write("Τμήματα:\n"),
    print_departments(RemovedDepartments,RemovedCourses),
    write("Μαθήματα:\n"),
    print_courses(RemovedCourses),
    length(RemovedCourses,RemovedCoursesAmount),
    length(RemovedDepartments,RemovedDepartmentsAmount),
    length(RemovedUniversities,RemovedUniversitiesAmount),
    format("Συνολικός Αριθμός Πανεπιστημίων: ~w\nΣυνολικός Αριθμός Τμημάτων: ~w\nΣυνολικός Αριθμός Μαθημάτων: ~w\n\n",[RemovedUniversitiesAmount,RemovedDepartmentsAmount,RemovedCoursesAmount]),
    format("Προστέθηκαν το ~w-~w σε σχέση με το ~w-~w:\n\n",[Year2,NextYear2,Year1,NextYear1]),
    write("Πανεπιστήμια:\n"),
    print_universities(AddedUniversities,AddedDepartments,AddedCourses),
    write("Τμήματα:\n"),
    print_departments(AddedDepartments,AddedCourses),
    write("Μαθήματα:\n"),
    print_courses(AddedCourses),
    length(AddedCourses,AddedCoursesAmount),
    length(AddedDepartments,AddedDepartmentsAmount),
    length(AddedUniversities,AddedUniversitiesAmount),
    format("Συνολικός Αριθμός Πανεπιστημίων: ~w\nΣυνολικός Αριθμός Τμημάτων: ~w\nΣυνολικός Αριθμός Μαθημάτων: ~w\n",[AddedUniversitiesAmount,AddedDepartmentsAmount,AddedCoursesAmount]).

one_book_two_year_comparison(_).

/*
filter_courses_by_department/4         filter_courses_by_department([Courses],[Departments],Year,[FilteredCourses])
Το filter_courses_by_department/4 ελαχιστοποιει μια λιστα μαθηματων ωστε να μην υπαρχουν περισσοτερα απο ενα μαθηματα με ιδιο ονομα,ιδιο τμημα και ιδιο ετος διδαξης    
*/

filter_courses_by_department(_,[],_,FilteredCourses):-
    FilteredCourses=[],
    true.

filter_courses_by_department(Courses,[DepartmentID|RestDepartments],Year,CoursesFiltered):-
    find_courses(Courses,DepartmentID,MatchingCourses,Year),
    findall(CourseName,(member(CourseID,MatchingCourses),course(CourseID,CourseName,Year,DepartmentID)),CourseNames),
    filter_duplicate_courses(MatchingCourses,CourseNames,UniqueCourses),
    filter_courses_by_department(Courses,RestDepartments,Year,RestCourses),
    append(RestCourses,UniqueCourses,CoursesFiltered).

/*
filter_duplicate_courses/3             filter_duplicate_courses([Courses],[Names],[NonDuplicateCourses])
Το filter_duplicate_courses/3 παιρνει μια λιστα κωδικων μαθηματων και μια λιστα ονοματων μαθηματων και αφαιρει κωδικους ωστε να μην υπαρχουν μαθηματα με ιδιο ονομα
*/

filter_duplicate_courses([],[],[]).

filter_duplicate_courses([_|Courses],[Name|Names],UniqueCourses):-
    member(Name,Names),
    !,
    filter_duplicate_courses(Courses,Names,UniqueCourses).

filter_duplicate_courses([Course|Courses],[_Name|Names],[Course|UniqueCourses]):-
    filter_duplicate_courses(Courses,Names,UniqueCourses).

/*
print_courses/1          print_courses([Courses])
Το print_courses/1 εμφανιζει μια λιστα με μαθηματα μαζι με το τμημα που ανηκουν και το πανεπιστημιο
*/

print_courses([]):-
    write("\n"),
    true.

print_courses([Course|Courses]):-
    course(Course,CourseName,_,DepartmentID),
    department(DepartmentID,DepartmentName,university(UniversityID)),
    university(UniversityID,UniversityName),
    format("~w, ΤΜΗΜΑ ~w, ~w\n",[CourseName,DepartmentName,UniversityName]),
    print_courses(Courses).

print_universities([],_,_):-
    write("\n"),
    true.

/*
print_universities/3           print_universities([Universities],[Departments],[Coourses])
Το print_universities/3 εκτυπωνει μια λιστα πανεμιστημιων μαζι με τα τμηματα και μαθηματα που ταιριαζουν σε αυτα και βρισκονται στις λιστες των παραμετρων
*/

print_universities([University|Universities],Departments,Courses):-
    university(University,UniversityName),
    findall(DepartmentID,(member(DepartmentID,Departments),department(DepartmentID,_,university(University))),MatchingDepartments),
    write(UniversityName),
    print_departments2(MatchingDepartments,Courses),
    print_universities(Universities,Departments,Courses).

/*
print_departments/2            print_departments([Departments],[Courses])
Το print_departments/2 εκτυπωνει μια λιστα τμηματων μαζι με το πανεπιστημιο που ανηκουν και τα μαθηματα που τους ανηκουν απο μια λιστα μαθηματων
*/

print_departments([],_):-
    write("\n"),
    true.

print_departments([Department|Departments],Courses):-
    department(Department,DepartmentName,university(UniversityID)),
    university(UniversityID,UniversityName),
    find_courses(Courses,Department,MatchingCourses,_),
    length(MatchingCourses,Len),
    findall(CourseName,(member(CourseID,MatchingCourses),course(CourseID,CourseName,_,_)),CourseNames),
    atomic_list_concat(CourseNames,',',CourseNamesClean),
    format("ΤΜΗΜΑ ~w, ~w, Μαθήματα (~w): ~w.\n",[DepartmentName,UniversityName,Len,CourseNamesClean]),
    print_departments(Departments,Courses).

/*
print_departments2/2            print_departments2([Departments],[Courses])
Εναλλαγη του print_departments/2 με διαφορετικη μορφη εκτυπωσης
*/

print_departments2([],_):-
    write("\n"),
    true.

print_departments2([Dep|RestDep],Courses):-
    find_courses(Courses,Dep,MatchingCourses,_),
    length(MatchingCourses,Len),
    department(Dep,DepName,university(_)),
    findall(CourseName,(member(CourseID,MatchingCourses),course(CourseID,CourseName,_,_)),CourseNames),
    atomic_list_concat(CourseNames,',',CourseNamesClean),
    format(", ΤΜΗΜΑ ~w, Μαθήματα (~w): ~w.",[DepName,Len,CourseNamesClean]),
    print_departments2(RestDep,Courses).

/*
course_list_remover/3         course_list_remover([CourseList],[CoursesToBeRemoved],[Result])
Το βοηθητικο κατηγορημα course_list_remover/3 παραγει μια καινουργια λιστα που προκυπτει απο την αφαιρεση των μαθηματων της δευτερης λιστας απο την πρωτη
Επειδη ο κωδικος ενος μαθηματος αλλαζει απο χρονια σε χρονια δεν ειναι δυνατον να αφαιρεσουμε τα μαθηματα μιας χρονιας απο τα μαθηματα μιας αλλης με τις ετοιμες συναρτησεις του prolog
Αρα δημιουργηθηκε αυτο το κατηγορημα που παιρνει αναδρομικα καθε μαθημα της πρωτης λιστας και ελεγχει αν υπαρχει μαθημα με ιδιο ονμα και ιδιο τμημα στην δευτερη λιστα
*/

course_list_remover([],_,[]).


course_list_remover([Course|RestCourses],CoursesToRemove,[Course|Result]):-
    course(Course,Name,_,Department),
    findall(CourseID,(member(CourseID,CoursesToRemove),course(CourseID,Name,_,Department)),MatchingCourses),
    length(MatchingCourses,0),
    !,
    course_list_remover(RestCourses,CoursesToRemove,Result).

course_list_remover([_Course|RestCourses],CoursesToRemove,Result):-
    course_list_remover(RestCourses,CoursesToRemove,Result).

/*
two_book_one_year_comparison/1            two_book_one_year_comparison(Option)
Το two_book_one_year_comparison/1 υλοποιε την τεταρτη επιλογη
Εμφανιζει το συνολο των στατιστικων των διαφορων μεταξυ δυο βιβλιων στο ιδιο ετος
 */

two_book_one_year_comparison(X):-
    X==4,
    write("\nΣύγκριση στατιστικών 2 βιβλίων για  1 έτος\n=========================================\nΔώσε τον κωδικό του πρώτου βιβλίου\n"),
    read(BookID1),
    write("Δώσε τον κωδικό του δεύτερου βιβλίου\n"),
    read(BookID2),
    write("Δώσε το έτος\n"),
    read(Year),
    book_check(BookID1),
    book_check(BookID2),
    book(BookID1,BookName1),
    book(BookID2,BookName2),
    NextYear is Year+1,
    format("\n\nΑκαδημαϊκο έτος:~w-~w\n\n",[Year,NextYear]),
    format("\nΒιβλίο: ~w - ~w",[BookID1,BookName1]),
    format("\nΒιβλίο: ~w - ~w\n\n",[BookID2,BookName2]),
    write("Βιβλίο        Πανεπιστήμια     Τμήματα     Μαθήματα\n"),
    statistics_sum_1_year(BookID1,Year,UniversitiesSum1,DepartmentSum1,CourseSum1),
    statistics_sum_1_year(BookID2,Year,UniversitiesSum2,DepartmentSum2,CourseSum2),
    format("~w~t~w~16|~t~w~33|~t~w~45|\n",[BookID1,UniversitiesSum1,DepartmentSum1,CourseSum1]),
    format("~w~t~w~16|~t~w~33|~t~w~45|",[BookID2,UniversitiesSum2,DepartmentSum2,CourseSum2]).

two_book_one_year_comparison(_).

/*
two_book_university_comparison/1             two_book_university_comparison(Option)
Το two_book_university_comparison/1 υλοποιε την πεμπτη επιλογη
Εμφανιζει αναλυτικα την διαφορα των πανεπιστημιων μεταξυ δυο βιβλιων στο ιδιο ετος
*/

two_book_university_comparison(X):-
    X==5,
    write("\nΣύγκριση 2 βιβλίων: Πανεπιστήμια που διατίθεται το 1ο σε σχέση με το 2ο\n=========================================\nΔώσε τον κωδικό του πρώτου βιβλίου\n"),
    read(BookID1),
    write("Δώσε τον κωδικό του δεύτερου βιβλίου\n"),
    read(BookID2),
    write("Δώσε το έτος\n"),
    read(Year),
    book_check(BookID1),
    book_check(BookID2),
    book(BookID1,BookName1),
    book(BookID2,BookName2),
    NextYear is Year+1,
    write(("\nΣύγκριση βιβλίων:")),
    format("\n~w - ~w",[BookID1,BookName1]),
    format("\n~w - ~w\n\n",[BookID2,BookName2]),
    format("Ακαδημαϊκο έτος: ~w-~w\n\n",[Year,NextYear]),
    findall(CourseID,(course_book(CourseID,BookID1),course(CourseID,_,Year,_)),Courses1),
    findall(CourseID,(course_book(CourseID,BookID2),course(CourseID,_,Year,_)),Courses2),
    findall(DepartmentID,(member(CourseID,Courses1),course(CourseID,_,Year,DepartmentID)),Departments1),
    findall(DepartmentID,(member(CourseID,Courses2),course(CourseID,_,Year,DepartmentID)),Departments2),
    sort(Departments1,Departments1Sorted),
    sort(Departments2,Departments2Sorted),
    filter_courses_by_department(Courses1,Departments1Sorted,Year,Courses1Filtered),
    filter_courses_by_department(Courses2,Departments2Sorted,Year,Courses2Filtered),
    subtract(Courses1Filtered,Courses2Filtered,MissingCourses),
    findall(UniversityID,(member(DepartmentID,Departments1Sorted),department(DepartmentID,_,university(UniversityID))),Universities1),
    findall(UniversityID,(member(DepartmentID,Departments2Sorted),department(DepartmentID,_,university(UniversityID))),Universities2),
    subtract(Departments1Sorted,Departments2Sorted,MissingDepartments),
    sort(Universities1,Universities1Sorted),
    sort(Universities2,Universities2Sorted),
    subtract(Universities1Sorted,Universities2Sorted,MissingUniversities),
    write("Πανεπιστήμια που χρησιμοποιούν το πρώτο βιβλίο αλλά όχι το δεύτερο:\n\n"),
    print_universities(MissingUniversities,MissingDepartments,MissingCourses),
    length(MissingUniversities,Len),
    format("Συνολικός αριθμός Πανεπιστημίων: ~w",[Len]).

two_book_university_comparison(_).

/*
two_book_department_comparison/1            two_book_department_comparison(Option)
Το two_book_department_comparison/1 υλοποιει την εκτη επιλογη
Εμφανιζει αναλυτικα την διαφορα των τμηματων μεταξυ δυο βιβλιων στο ιδιο ετος
*/

two_book_department_comparison(X):-
    X==6,
    write("\nΣύγκριση 2 βιβλίων: Τμήματα που διατίθεται το 1ο σε σχέση με το 2ο\n=========================================\nΔώσε τον κωδικό του πρώτου βιβλίου\n"),
    read(BookID1),
    write("Δώσε τον κωδικό του δεύτερου βιβλίου\n"),
    read(BookID2),
    write("Δώσε το έτος\n"),
    read(Year),
    book_check(BookID1),
    book_check(BookID2),
    book(BookID1,BookName1),
    book(BookID2,BookName2),
    NextYear is Year+1,
    write("\nΣύγκριση βιβλίων:"),
    format("\n~w - ~w",[BookID1,BookName1]),
    format("\n~w - ~w\n\n",[BookID2,BookName2]),
    format("Ακαδημαϊκο έτος: ~w-~w\n\n",[Year,NextYear]),
    findall(CourseID,(course_book(CourseID,BookID1),course(CourseID,_,Year,_)),Courses1),
    findall(CourseID,(course_book(CourseID,BookID2),course(CourseID,_,Year,_)),Courses2),
    findall(DepartmentID,(member(CourseID,Courses1),course(CourseID,_,Year,DepartmentID)),Departments1),
    findall(DepartmentID,(member(CourseID,Courses2),course(CourseID,_,Year,DepartmentID)),Departments2),
    sort(Departments1,Departments1Sorted),
    sort(Departments2,Departments2Sorted),
    filter_courses_by_department(Courses1,Departments1Sorted,Year,Courses1Filtered),
    filter_courses_by_department(Courses2,Departments2Sorted,Year,Courses2Filtered),
    subtract(Courses1Filtered,Courses2Filtered,MissingCourses),
    subtract(Departments1Sorted,Departments2Sorted,MissingDepartments),
    write("Τμήματα που χρησιμοποιούν το πρώτο βιβλίο αλλά όχι το δεύτερο:\n\n"),
    print_departments(MissingDepartments,MissingCourses),
    length(MissingDepartments,Len),
    format("Συνολικός αριθμός Τμημάτων: ~w",[Len]).

two_book_department_comparison(_).

/*
two_book_courses_comparison/1            two_book_courses_comparison(Option)
Το two_book_courses_comparison/1 υλοποιει την εβδομη επιλογη
Εμφανιζει αναλυτικα την διαφορα των μαθηματων μεταξυ δυο βιβλιων στο ιδιο ετος
*/

two_book_courses_comparison(X):-
    X==7,
    write("\nΣύγκριση 2 βιβλίων: Μαθήματα που διατίθεται το 1ο σε σχέση με το 2ο\n=========================================\nΔώσε τον κωδικό του πρώτου βιβλίου\n"),
    read(BookID1),
    write("Δώσε τον κωδικό του δεύτερου βιβλίου\n"),
    read(BookID2),
    write("Δώσε το έτος\n"),
    read(Year),
    book_check(BookID1),
    book_check(BookID2),
    book(BookID1,BookName1),
    book(BookID2,BookName2),
    NextYear is Year+1,
    write("\nΣύγκριση βιβλίων:"),
    format("\n~w - ~w",[BookID1,BookName1]),
    format("\n~w - ~w\n\n",[BookID2,BookName2]),
    format("Ακαδημαϊκο έτος: ~w-~w\n\n",[Year,NextYear]),
    findall(CourseID,(course_book(CourseID,BookID1),course(CourseID,_,Year,_)),Courses1),
    findall(CourseID,(course_book(CourseID,BookID2),course(CourseID,_,Year,_)),Courses2),
    findall(DepartmentID,(member(CourseID,Courses1),course(CourseID,_,Year,DepartmentID)),Departments1),
    findall(DepartmentID,(member(CourseID,Courses2),course(CourseID,_,Year,DepartmentID)),Departments2),
    sort(Departments1,Departments1Sorted),
    sort(Departments2,Departments2Sorted),
    filter_courses_by_department(Courses1,Departments1Sorted,Year,Courses1Filtered),
    filter_courses_by_department(Courses2,Departments2Sorted,Year,Courses2Filtered),
    subtract(Courses1Filtered,Courses2Filtered,MissingCourses),
    write("Μαθήματα που χρησιμοποιούν το πρώτο βιβλίο αλλά όχι το δεύτερο:\n\n"),
    print_courses(MissingCourses),
    length(MissingCourses,Len),
    format("Συνολικός αριθμός Μαθημάτων: ~w",[Len]).

two_book_courses_comparison(_).

/*
exit/1        exit(Option)
Το exit/1 υλοποιει την επιλογη τελους του προγραμματος
Εκτυπωνει ενα αποχαιρετιστηριο  μηνυμα και πεταει ενα error το οποιο πιανει η run/ και τελειωνει το προγραμμα με true
*/

exit(X):-
    X==0,
    write("Θα τα ξαναπούμε!"),
    throw(exit_command).

exit(_).

/*
wrong_option/1       wrong_option(Option)
Το wrong_option/1 υλοποιει την περιπτωση τιμης εκτος του ευρους [0,7]
Εμφανιζει απλα ενα μηνυμα λαθους
*/

wrong_option(X):-
    X>=8,
    write("Δώσε έναν αριθμό μεταξύ 0 και 7!").

wrong_option(X):-
    X<0,
    write("Δώσε έναν αριθμό μεταξύ 0 και 7!").

wrong_option(_).

/*
book_check/1         book_check(BookID)
Το book_check/1 ειναι ενα κατηγορημα που ελεγει ενα ο κωδικος του βιβλιου ειναι σωστος, δηλαδη αν αντιστοιχει σε τουλαχιστον 1 μαθημα
Καλειται μετα απο καθε αναγνωση κωδικου βιβλιου σε ολα τα υπολοιπα κατηγορηματα
Αν ο κωδικος ειναι σωστος επιστρεφει true και συνεχιζει κανονικα
Αν ο κωδικος ειναι λαθος εμφανιζει μηνυμα σφαλματος και επιστρεφει false, οδηγοντας το κατηγορημα που το καλεσε να να παυσει την εκτελεση του και την prolog να κανει backtrack στον
default catch all κανονα του κατηγορηματος ωστε συνεχισει την εκτελεση του το run2/ μεχρι την επαναληψη του
*/

book_check(Book):-
    course_book(_,Book),
    !.

book_check(Book):-
    format('~nΔεν βρέθηκε βιβλίο με τον κωδικό: ~w', [Book]),
    fail.
    






