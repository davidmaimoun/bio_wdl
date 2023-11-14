version 1.0

workflow WORKFLOW {
    input {
        Array[File] files
    }

    call CHECK_INPUT_READS {
        input:
            files = files
    }
}

task CHECK_INPUT_READS {
  input {
    Array[File] files
    Int length_input = length(files)
  }

 
  command <<<
    set -e

    if [[ ~{length_input} =  0 ]]; then
        echo "ERROR: You need Inputs my friend"
        exit 1;
    fi

    if [ $((~{length_input} % 2)) -eq 0 ]; then
        ARRAY=(~{sep=" " files})
        R1=()
        R2=()

        for file in "${ARRAY[@]}"; do
            if [[ ${file} == *"_R1."* ]]; then
                R1+=(${file})
            elif [[ ${file} == *"_R2."* ]]; then
                R2+=(${file})
            fi
        done

        if [[ "${#R1[@]}" -ne  "${#R2[@]}" ]]; then
            echo "ERROR: Your R1 and R2 files are not equal."
            exit 1;
        fi

    else
        echo "ERROR: Your data in not paire ended."
        exit 1;
    fi


    exit 0;
  >>>

  runtime {
    docker: "ubuntu:18.04"
    cpu: 1
  }

   meta {
    description: "Checks input reads to ensure that the files are paire ended"
  }

}

