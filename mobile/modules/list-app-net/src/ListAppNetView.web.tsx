import * as React from 'react';

import { ListAppNetViewProps } from './ListAppNet.types';

export default function ListAppNetView(props: ListAppNetViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
