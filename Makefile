output_file := bin/chess
file := main.odin

build: main.odin
	odin build . -out:$(output_file)
clean:
	rm -f $(output_file)
run: $(output_file)
	$(output_file)
file: $(file)
	odin build $(file) -file -out:$(file).exe

