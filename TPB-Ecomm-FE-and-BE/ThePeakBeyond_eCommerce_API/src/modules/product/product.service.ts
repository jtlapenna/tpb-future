import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataBaseQueryEnum } from 'src/common/constants/database.query.enum';
import { ProductSearchDto } from 'src/models/dto/product-search.dto';
import {
  GET_FAVORITE_PRODUCTS,
  GET_FEATURED_PRODUCTS,
  GET_PRODUCTS,
  GET_PRODUCTS_BY_TAG,
  GET_PRODUCTS_ON_SALES,
  GET_PRODUCT_BY_ID,
  GET_PRODUCT_BY_SKU,
  GET_PRODUCT_TAGS,
} from 'src/database/products.query';
import { ProductDto } from 'src/models/dto/product.dto';
import { Product } from 'src/models/product/product.entity';
import { Repository } from 'typeorm';

@Injectable()
export class ProductService {
  constructor(
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
  ) {}

  async findAll(productSearch: ProductSearchDto): Promise<ProductDto[]> {
    const filterParams = [
      productSearch.storeId,
      productSearch?.count || DataBaseQueryEnum.COUNT,
      ((productSearch?.page || 1) - 1) *
        (productSearch?.count || DataBaseQueryEnum.COUNT),
      productSearch?.category || 0,
      productSearch?.brand || 0,
    ] as any;

    if (productSearch.tag) {
      filterParams.push(productSearch.tag);
    }
    if (productSearch.loadFavorites) {
      filterParams.push(productSearch.userId);
    }

    let searchCriteria = ' ORDER BY ';

    if (productSearch.name) {
      searchCriteria = ` AND (CTE.name ILIKE '%${productSearch.name}%' OR brands.name ILIKE '%${productSearch.name}%') ORDER BY `;
    }

    return this.productsRepository.query(
      (productSearch.loadFavorites
        ? GET_FAVORITE_PRODUCTS
        : productSearch.tag
        ? GET_PRODUCTS_BY_TAG
        : GET_PRODUCTS
      )
        .replace('{SORT_ORDER}', productSearch?.sortDirection || 'ASC')
        .replace('ORDER BY', searchCriteria)
        .replace(
          '{SORT_COLUMN}',
          productSearch?.random || productSearch?.sortColumn || 'id',
        ),
      filterParams,
    );
  }

  async findOnSales(productSearch: ProductSearchDto): Promise<ProductDto[]> {
    const filterParams = [
      productSearch.storeId,
      productSearch?.count || DataBaseQueryEnum.COUNT,
      ((productSearch?.page || 1) - 1) *
        (productSearch?.count || DataBaseQueryEnum.COUNT),
      productSearch?.category || 0,
      productSearch?.brand || 0,
    ];

    return this.productsRepository.query(
      GET_PRODUCTS_ON_SALES.replace(
        '{SORT_ORDER}',
        productSearch?.sortDirection || 'ASC',
      ).replace(
        '{SORT_COLUMN}',
        productSearch?.random || productSearch?.sortColumn || 'name',
      ),
      filterParams,
    );
  }

  async featuredProducts(
    productSearch: ProductSearchDto,
  ): Promise<ProductDto[]> {
    const filterParams = [
      productSearch.storeId,
      productSearch?.count || DataBaseQueryEnum.COUNT,
      ((productSearch?.page || 1) - 1) *
        (productSearch?.count || DataBaseQueryEnum.COUNT),
      productSearch?.category || 0,
      productSearch?.brand || 0,
    ];

    return this.productsRepository.query(
      GET_FEATURED_PRODUCTS.replace(
        '{SORT_ORDER}',
        productSearch?.sortDirection || 'ASC',
      ).replace(
        '{SORT_COLUMN}',
        productSearch?.random || productSearch?.sortColumn || 'name',
      ),
      filterParams,
    );
  }

  findTags(id: number): Promise<any> {
    return this.productsRepository.query(GET_PRODUCT_TAGS, [id]);
  }

  findOne(id: number): Promise<ProductDto[]> {
    return this.productsRepository.query(GET_PRODUCT_BY_ID, [id]);
  }

  findBySku(sku: string): Promise<ProductDto[]> {
    return this.productsRepository.query(GET_PRODUCT_BY_SKU, [sku]);
  }

  async highlights(storeId: number): Promise<ProductDto[]> {
    const productSearch: ProductSearchDto = {
      storeId,
      page: 1,
      count: 4,
      random: 'random()',
    };

    const onSales = await this.findOnSales(productSearch);
    const featured = await this.featuredProducts(productSearch);

    if (onSales.length + featured.length >= 4) {
      const result = [];

      for (let i = 0; i < Math.min(2, onSales.length); i++) {
        result.push(onSales[i]);
      }

      for (let i = 0; i < Math.min(2, featured.length); i++) {
        result.push(featured[i]);
      }

      if (result.length < 4) {
        const needed = 4 - result.length;
        if (featured.length < 2) {
          for (let i = 0; i < needed; i++) {
            result.push(onSales[i + 2]);
          }
        } else {
          for (let i = 0; i < needed; i++) {
            result.push(featured[i + 2]);
          }
        }
      }

      return result;
    }

    return this.findAll(productSearch);
  }
}
