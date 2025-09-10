import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'stores' })
export class Store {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ name: 'client_id' })
  clientId: number | null;

  @Column()
  tax: string | null;

  @Column()
  active: boolean | null;

  @Column({ name: 'created_at' })
  createdAt: Date | null;

  @Column({ name: 'api_settings' })
  apiSettings: string | null;
}
