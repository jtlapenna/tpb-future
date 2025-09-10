import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'store_categories' })
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'store_id' })
  storeId: number | null;

  @Column()
  name: string | null;

  @Column()
  order: number | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;
}
