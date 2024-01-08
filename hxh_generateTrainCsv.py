import csv

file_path = '/data/sam/SAM/sam_multi/queries/mscn_queries_neurocard_format.csv'
output_path = '/data/sam/SAM/sam_multi/queries/'

rows_to_extract = [10, 100, 1000, 10000, 100000]

for num_rows in rows_to_extract:
        output_file_path = f'{output_path}mscn_queries_neurocard_format_{num_rows}.csv'
        
        with open(file_path, 'r') as file:
            reader = csv.reader(file)
            
            with open(output_file_path, 'w', newline='') as output_file:
                writer = csv.writer(output_file)
                for _ in range(num_rows):
                    writer.writerow(next(reader))
        
        print(f'File {output_file_path} created.')
