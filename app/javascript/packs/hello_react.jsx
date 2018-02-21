// Run this example by adding <%= javascript_pack_tag 'hello_react' %>
// to the head of your layout file, like app/views/layouts/application.html.erb
// All it does is render <div>Hello React</div> at the bottom of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { Button, Icon, Label, Card, Image } from 'semantic-ui-react'

const Hello = props => <div>Hello {props.name}!</div>

Hello.defaultProps = {
  name: 'David'
}

Hello.propTypes = {
  name: PropTypes.string
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Hello name="React" />,
    document.body.appendChild(document.createElement('div'))
  )
})

const ButtonExampleLabeledBasic = () => (
  <div>
    <Button
      color="red"
      content="Like"
      icon="heart"
      label={{ basic: true, color: 'red', pointing: 'left', content: '2,048' }}
    />
    <Button
      basic
      color="blue"
      content="Fork"
      icon="fork"
      label={{
        as: 'a',
        basic: true,
        color: 'blue',
        pointing: 'left',
        content: '2,048'
      }}
    />
  </div>
)

const CardExampleCard = () => (
  <Card>
    <Image src="https://react.semantic-ui.com/assets/images/avatar/large/matthew.png" />
    <Card.Content>
      <Card.Header>Matthew</Card.Header>
      <Card.Meta>
        <span className="date">Joined in 2015</span>
      </Card.Meta>
      <Card.Description>
        Matthew is a musician living in Nashville.
      </Card.Description>
    </Card.Content>
    <Card.Content extra>
      <a>
        <Icon name="user" />
        22 Friends
      </a>
    </Card.Content>
  </Card>
)
const ButtonExampleIcon = () => (
  <Button icon>
    <Icon name="world" />
  </Button>
)

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <div>
      <CardExampleCard />
      <ButtonExampleLabeledBasic />
      <ButtonExampleIcon />
    </div>,
    document.body.appendChild(document.createElement('div'))
  )
})
