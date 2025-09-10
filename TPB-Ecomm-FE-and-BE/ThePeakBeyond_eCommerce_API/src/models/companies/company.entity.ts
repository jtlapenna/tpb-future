import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'clients' })
export class Company {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;

  @Column()
  active: boolean | null;
}
