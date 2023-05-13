
# This function exists to generate a test file that imports all of the code we
# are interested getting code coverage on. This is necessary because the
# flutter test --coverage only produces coverage for code that is reachable. In
# general this effectively is only for code that has associated test files. So
# files that have no test files are effectively ignored making the code
# coverage report incomplete and incorrect.
#
# this was based on https://medium.com/flutter-community/how-to-actually-get-test-coverage-for-your-flutter-applications-f881c0ae8155
#
# usage: generate_flutter_test_import_file <string-of-files-to-import> <package-name> <output-file-path>
generate_flutter_test_import_file() {
	files=$1
	package_name=$2
	output_file_path=$3
	echo "// Generated helper file to make coverage work for all dart files" > ${output_file_path}
	echo "// ignore_for_file: unused_import" >> ${output_file_path}
	echo "${files}" | cut -c4- | awk -v package="${package_name}" '{printf "import '\''package:%s%s'\'';\n", package, $1}' >> ${output_file_path}
	echo "\nvoid main() {}" >> ${output_file_path}
}
