def assemble(asm):
    lines = [i for i in asm.split("\n") if i != ""]
    labels = [lambda i : i.split()[0][:-1] for i in lines if ":" in i.split()[0]]
    return labels
