import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'tags' })
export class TagInfo {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;
}
