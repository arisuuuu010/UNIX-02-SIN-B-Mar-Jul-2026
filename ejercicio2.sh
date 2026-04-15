touch prueba.txt (Create an empty file named "prueba.txt" (or update its timestamp if it already exists).
chmod 600 prueba.txt (Set permissions so only the owner can read and write the file, with no access for others.)
ls -l prueba.txt (List the file details in long format to verify the "600" permissions.)
chmod 755 prueba.txt (Set permissions so the owner has full control (read, write, execute), while everyone else can only read and execute.)
ls -l prueba.txt (List the file details again to confirm the new "755" permission set.)