import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'brands' })
export class Brand {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  description: string | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;
}
