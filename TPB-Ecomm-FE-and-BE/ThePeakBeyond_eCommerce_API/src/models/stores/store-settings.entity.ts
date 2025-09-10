import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'store_settings' })
export class StoreSettings {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'store_id' })
  storeId: number | null;

  @Column()
  data: string | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;

  @Column({ name: 'updated_at' })
  updatedAt: string | null;
}
