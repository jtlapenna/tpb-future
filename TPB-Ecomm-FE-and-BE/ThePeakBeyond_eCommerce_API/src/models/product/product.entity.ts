import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

@Entity({ name: 'products' })
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string | null;

  @Column()
  description: string | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;

  // @ManyToOne(() => Category, (caetgory) => caetgory.products)
  // @JoinColumn({ name: 'category_id' })
  // category: Category;
}
